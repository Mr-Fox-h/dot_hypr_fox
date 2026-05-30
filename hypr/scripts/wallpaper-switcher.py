#!/usr/bin/env python3
import gi
import os
import subprocess
from pathlib import Path

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GdkPixbuf, GLib, GObject, Gdk

class WallpaperSwitcher(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Theme Wallpaper Switcher")
        
        # Set WM_CLASS for Hyprland
        self.set_wmclass("hyprwallpaper", "HyprWallpaper")
        
        # Window properties
        self.set_default_size(1000, 550)
        self.set_resizable(False)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_border_width(10)
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.set_decorated(True)
        
        # Get pictures directory
        self.pictures_dir = Path.home() / "Pictures"
        if not self.pictures_dir.exists():
            self.show_error_dialog(f"Directory not found: {self.pictures_dir}")
            return
        
        # Store all image paths and widgets
        self.image_widgets = []  # List of (img_path, flowbox_child)
        self.loading_complete = False
        
        # Create main container with margin
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        main_box.set_margin_start(10)
        main_box.set_margin_end(10)
        main_box.set_margin_top(10)
        main_box.set_margin_bottom(10)
        self.add(main_box)
        
        # === Search Bar ===
        search_box = Gtk.Box(spacing=6)
        search_box.set_margin_top(10)
        search_box.set_margin_bottom(10)
        
        self.search_entry = Gtk.SearchEntry()
        self.search_entry.set_placeholder_text("🔍 Search wallpapers (e.g., nature, BG, forest)...")
        self.search_entry.set_hexpand(True)
        self.search_entry.connect("search-changed", self.on_search_changed)
        search_box.pack_start(self.search_entry, True, True, 0)
        
        main_box.pack_start(search_box, False, False, 0)
        
        # === Overlay for loading indicator ===
        self.overlay = Gtk.Overlay()
        main_box.pack_start(self.overlay, True, True, 0)
        
        # Scrolled window for images
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        self.overlay.add(scrolled)
        
        # FlowBox for images
        self.flowbox = Gtk.FlowBox()
        self.flowbox.set_valign(Gtk.Align.START)
        self.flowbox.set_max_children_per_line(10)
        self.flowbox.set_selection_mode(Gtk.SelectionMode.SINGLE)
        scrolled.add(self.flowbox)
        
        # Loading overlay box (centered)
        self.loading_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.loading_box.set_halign(Gtk.Align.CENTER)
        self.loading_box.set_valign(Gtk.Align.CENTER)
        
        self.spinner = Gtk.Spinner()
        self.spinner.start()
        self.loading_box.pack_start(self.spinner, False, False, 0)
        
        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_size_request(300, -1)
        self.loading_box.pack_start(self.progress_bar, False, False, 0)
        
        self.loading_label = Gtk.Label(label="Scanning for images...")
        self.loading_box.pack_start(self.loading_label, False, False, 0)
        
        # Add loading overlay on top
        self.overlay.add_overlay(self.loading_box)
        
        # Status bar
        self.status_label = Gtk.Label()
        self.status_label.set_halign(Gtk.Align.START)
        main_box.pack_start(self.status_label, False, False, 0)
        
        # Button box with margins
        button_box = Gtk.Box(spacing=10)
        button_box.set_margin_bottom(10)
        button_box.set_margin_start(10)
        button_box.set_margin_end(10)
        main_box.pack_start(button_box, False, False, 0)
        
        # Apply button
        self.apply_button = Gtk.Button(label="Apply Selected")
        self.apply_button.set_sensitive(False)
        self.apply_button.connect("clicked", self.on_apply_clicked)
        button_box.pack_end(self.apply_button, False, False, 0)
        
        # Close button
        close_button = Gtk.Button(label="Close")
        close_button.connect("clicked", self.on_close_clicked)
        button_box.pack_end(close_button, False, False, 0)
        
        # Connect selection changed
        self.flowbox.connect("selected-children-changed", self.on_selection_changed)
        
        # Handle window close
        self.connect("destroy", Gtk.main_quit)
        self.connect("key-press-event", self.on_key_press)
        
        # Start asynchronous loading
        self.load_images_async()
    
    def load_images_async(self):
        """Start background thread to scan images, then load thumbnails in batches"""
        def scan_images():
            supported_formats = {'.png', '.jpg', '.jpeg', '.webp', '.svg', '.bmp', '.tiff', '.gif'}
            image_files = []
            try:
                for root, dirs, files in os.walk(str(self.pictures_dir)):
                    # Skip hidden directories
                    dirs[:] = [d for d in dirs if not d.startswith('.')]
                    for file in files:
                        if Path(file).suffix.lower() in supported_formats:
                            img_path = Path(root) / file
                            image_files.append(img_path)
            except Exception as e:
                GLib.idle_add(self.show_error_dialog, f"Error scanning directory: {e}")
                return
            
            image_files.sort()
            GLib.idle_add(self.start_thumbnail_loading, image_files)
        
        from threading import Thread
        thread = Thread(target=scan_images)
        thread.daemon = True
        thread.start()
    
    def start_thumbnail_loading(self, image_files):
        """Initialize progress bar and start adding thumbnails in chunks"""
        if not image_files:
            self.loading_box.destroy()
            self.status_label.set_text("No images found in ~/Pictures or its subfolders")
            self.loading_complete = True
            return
        
        self.total_images = len(image_files)
        self.loaded_count = 0
        self.progress_bar.set_fraction(0.0)
        self.loading_label.set_text(f"Loading {self.total_images} thumbnails...")
        
        # Start adding thumbnails in chunks
        self.image_files_iter = iter(image_files)
        self.add_thumbnail_chunk()
    
    def add_thumbnail_chunk(self, chunk_size=5):
        """Add a chunk of thumbnails, then schedule next chunk via idle"""
        added = 0
        for _ in range(chunk_size):
            try:
                img_path = next(self.image_files_iter)
            except StopIteration:
                # Done loading all thumbnails
                self.loading_complete = True
                self.loading_box.destroy()
                self.status_label.set_text(f"Loaded {self.total_images} images")
                return
            
            # Create widget in main thread (GdkPixbuf must be in main thread)
            child = self.create_image_widget(img_path)
            self.image_widgets.append((img_path, child))
            self.flowbox.add(child)
            self.loaded_count += 1
            
            # Update progress
            fraction = self.loaded_count / self.total_images
            self.progress_bar.set_fraction(fraction)
            self.loading_label.set_text(f"Loading thumbnails... {self.loaded_count}/{self.total_images}")
            added += 1
        
        if added > 0:
            # Show the new widgets immediately
            self.flowbox.show_all()
            # Schedule next chunk
            GLib.idle_add(self.add_thumbnail_chunk, chunk_size)
    
    def create_image_widget(self, img_path):
        """Create a FlowBoxChild with thumbnail and filename (must be called in main thread)"""
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(str(img_path), 200, 150)
            image = Gtk.Image.new_from_pixbuf(pixbuf)
        except Exception:
            image = Gtk.Image.new_from_icon_name("image-missing", Gtk.IconSize.DIALOG)
            image.set_pixel_size(100)
        
        rel_path = img_path.relative_to(self.pictures_dir)
        filename_label = Gtk.Label(label=str(rel_path))
        filename_label.set_ellipsize(1)
        filename_label.set_max_width_chars(25)
        filename_label.set_tooltip_text(str(img_path))
        
        vbox.pack_start(image, False, False, 0)
        vbox.pack_start(filename_label, False, False, 0)
        
        child = Gtk.FlowBoxChild()
        child.add(vbox)
        child.set_tooltip_text(str(img_path))
        child.img_path = img_path
        child.search_text = str(rel_path).lower()  # Cache for fast search
        child.original_label = filename_label
        
        return child
    
    def on_search_changed(self, entry):
        """Filter images based on search query (only after loading complete)"""
        if not self.loading_complete:
            return  # Wait until loading finished
        
        query = entry.get_text().strip().lower()
        visible_count = 0
        
        for img_path, child in self.image_widgets:
            match = query in child.search_text
            child.set_visible(match)
            if match:
                visible_count += 1
        
        # Update selection state
        selected = self.flowbox.get_selected_children()
        if not selected:
            self.apply_button.set_sensitive(False)
        
        # Update status
        total = len(self.image_widgets)
        self.status_label.set_text(
            f"Showing {visible_count} of {total} images" if query
            else f"Loaded {total} images"
        )
    
    def on_selection_changed(self, flowbox):
        selected = flowbox.get_selected_children()
        self.apply_button.set_sensitive(len(selected) > 0)
    
    def on_apply_clicked(self, button):
        if not self.loading_complete:
            return
        selected = self.flowbox.get_selected_children()
        if not selected:
            return
        
        img_path = selected[0].img_path
        self.status_label.set_text(f"Applying: {img_path.name}...")
        self.apply_button.set_sensitive(False)
        
        # Run matugen in background
        self.run_matugen(img_path)
    
    def run_matugen(self, img_path):
        """Execute matugen command asynchronously"""
        def run_command():
            try:
                subprocess.run(
                    ["matugen", "image", str(img_path), "--source-color-index", "0"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    check=True
                )
                GLib.idle_add(self.on_success, img_path.name)
            except subprocess.CalledProcessError as e:
                GLib.idle_add(self.on_error, f"matugen failed: {e}")
            except FileNotFoundError:
                GLib.idle_add(self.on_error, "matugen not found. Install it first!")
        
        from threading import Thread
        thread = Thread(target=run_command)
        thread.daemon = True
        thread.start()
    
    def on_success(self, filename):
        self.status_label.set_text(f"Applied: {filename}")
        # ✅ EXIT IMMEDIATELY AFTER APPLYING
        GLib.timeout_add(800, self.destroy)  # Delay slightly so user sees success message
    
    def on_error(self, error_msg):
        self.status_label.set_text(f"Error: {error_msg}")
        self.apply_button.set_sensitive(True)
        self.show_error_dialog(error_msg)
    
    def show_error_dialog(self, message):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            flags=0,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.CLOSE,
            text="Error"
        )
        dialog.format_secondary_text(message)
        dialog.run()
        dialog.destroy()
    
    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
    
    def on_close_clicked(self, button):
        self.destroy()

if __name__ == "__main__":
    app = WallpaperSwitcher()
    app.show_all()
    Gtk.main()
