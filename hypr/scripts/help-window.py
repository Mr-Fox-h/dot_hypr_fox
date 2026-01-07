#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk

class KeybindWindow(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Hyprland Keybinds")
        
        # Set window properties for Hyprland to identify
        self.set_wmclass("hyprkeybinds", "HyprKeybinds")
        
        # Set fixed size (width, height)
        self.set_default_size(1000, 550)
        self.set_resizable(False)
        self.set_position(Gtk.WindowPosition.CENTER)
        
        # Create main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(main_box)
        
        # Header
        header = Gtk.Label()
        header.set_markup("<big><b>Hyprland Keybinds</b></big>")
        header.set_margin_top(10)
        header.set_margin_bottom(10)
        main_box.pack_start(header, False, False, 0)
        
        # Create a notebook (tabbed interface) for sections
        notebook = Gtk.Notebook()
        notebook.set_tab_pos(Gtk.PositionType.TOP)
        main_box.pack_start(notebook, True, True, 0)
        
        # Define sections with their keybinds
        sections = {
            "   Window Management": [
                ("Super + Q", "Close Active Window"),
                ("Super + F", "Toggle Fullscreen"),
                ("Super + Alt + Space", "Toggle Floating"),
                ("Super + P", "Pseudo Tiling (Dwindle)"),
                ("Super + J", "Toggle Split (Dwindle)"),
                ("Super + left", "Move Focus Left"),
                ("Super + right", "Move Focus Right"),
                ("Super + up", "Move Focus Up"),
                ("Super + down", "Move Focus Down"),
            ],
            
            "   Applications": [
                ("Super + T", "Open Terminal"),
                ("Super + E", "Open File Manager"),
                ("Super + Tab", "Open App Launcher"),
                ("Super + Y", "Open hyprlauncher"),
                ("Super + W", "Open Zen Browser"),
                ("Super + M", "Open Music Player"),
                ("Super + End", "Open System Monitor (btop)"),
            ],
            
            "   Media & Screenshots": [
                ("Print", "Screenshot Window"),
                ("Super + Shift + S", "Screenshot Region"),
            ],
            
            "   OS & System": [
                ("Super + L", "Lock Screen"),
                ("Ctrl + Alt + Delete", "Logout Menu"),
                ("Super + I", "System Information"),
                ("Super + R", "Restart Waybar"),
                ("Super + N", "Toggle Notifications"),
                ("Super + H", "Open This Help Window"),
                ("Super + B", "Open Change Background Window"),
                ("Super + C", "Color Picker"),
                ("Super + Space", "Change Language Layout"),
            ],
            
            "󰨇   Workspaces": [
                ("Super + 1", "Switch to Workspace 1"),
                ("Super + 2", "Switch to Workspace 2"),
                ("Super + 3", "Switch to Workspace 3"),
                ("Super + 4", "Switch to Workspace 4"),
                ("Super + 5", "Switch to Workspace 5"),
                ("Super + 6", "Switch to Workspace 6"),
                ("Super + 7", "Switch to Workspace 7"),
                ("Super + 8", "Switch to Workspace 8"),
                ("Super + 9", "Switch to Workspace 9"),
                ("Super + 0", "Switch to Workspace 10"),
                ("Super + Shift + 1", "Move Window to Workspace 1"),
                ("Super + Shift + 2", "Move Window to Workspace 2"),
                ("Super + Shift + 3", "Move Window to Workspace 3"),
                ("Super + Shift + 4", "Move Window to Workspace 4"),
                ("Super + Shift + 5", "Move Window to Workspace 5"),
                ("Super + Shift + 6", "Move Window to Workspace 6"),
                ("Super + Shift + 7", "Move Window to Workspace 7"),
                ("Super + Shift + 8", "Move Window to Workspace 8"),
                ("Super + Shift + 9", "Move Window to Workspace 9"),
                ("Super + Shift + 0", "Move Window to Workspace 10"),
            ],
            
            "󱄄   Special Workspaces": [
                ("Super + S", "Toggle Special Workspace 'magic'"),
                ("Super + Alt + S", "Move Window to Special Workspace"),
                ("Super + mouse_down", "Next Workspace"),
                ("Super + mouse_up", "Previous Workspace"),
            ],
        }
        
        # Create a page for each section
        for section_name, keybinds in sections.items():
            # Create scrolled window for this section
            scrolled = Gtk.ScrolledWindow()
            scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
            
            # Create list store for this section
            liststore = Gtk.ListStore(str, str)
            for key, action in keybinds:
                liststore.append([key, action])
            
            # Create tree view
            treeview = Gtk.TreeView(model=liststore)
            
            # Create columns
            renderer_key = Gtk.CellRendererText()
            column_key = Gtk.TreeViewColumn("Keybind", renderer_key, text=0)
            column_key.set_expand(True)
            column_key.set_min_width(200)
            treeview.append_column(column_key)
            
            renderer_action = Gtk.CellRendererText()
            column_action = Gtk.TreeViewColumn("Action", renderer_action, text=1)
            column_action.set_expand(True)
            column_action.set_min_width(300)
            treeview.append_column(column_action)
            
            # Style
            treeview.set_headers_visible(True)
            treeview.set_grid_lines(Gtk.TreeViewGridLines.HORIZONTAL)
            treeview.set_margin_start(10)
            treeview.set_margin_end(10)
            
            scrolled.add(treeview)
            
            # Add to notebook with tab label
            label = Gtk.Label(label=section_name)
            notebook.append_page(scrolled, label)
        
        # Close button
        button_box = Gtk.Box(spacing=10)
        button_box.set_margin_bottom(10)
        button_box.set_margin_start(10)
        button_box.set_margin_end(10)
        main_box.pack_start(button_box, False, False, 0)
        
        close_button = Gtk.Button(label="Close")
        close_button.connect("clicked", self.on_close_clicked)
        button_box.pack_end(close_button, False, False, 0)
        
        # Style
        self.set_border_width(10)
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.set_decorated(True)
        self.connect("key-press-event", self.on_key_press)
    
    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
    
    def on_close_clicked(self, button):
        self.destroy()

if __name__ == "__main__":
    win = KeybindWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
