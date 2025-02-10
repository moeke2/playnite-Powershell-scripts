import os
import shutil
import tkinter as tk
from tkinter import messagebox
import ctypes

# Configuration paths
BASE_DIR = r"D:\Games\Nordic Souls\profiles\Nordic Souls"
INI_SWAP_DIR = os.path.join(BASE_DIR, "INI swap")
TRACKER_FILE = os.path.join(INI_SWAP_DIR, "current_resolution.txt")


def get_current_resolution():
    """Read the current resolution from tracker file"""
    try:
        with open(TRACKER_FILE, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        return None
    except Exception as e:
        messagebox.showerror("Error", f"Failed to read tracker file:\n{str(e)}")
        return None


def set_current_resolution(resolution):
    """Update the resolution tracker file"""
    try:
        with open(TRACKER_FILE, 'w') as f:
            f.write(resolution)
        return True
    except Exception as e:
        messagebox.showerror("Error", f"Failed to update tracker file:\n{str(e)}")
        return False


def copy_ini_files(resolution):
    """Copy INI files from selected resolution folder to base directory"""
    source_dir = os.path.join(INI_SWAP_DIR, resolution)

    if not os.path.exists(source_dir):
        messagebox.showerror("Error", f"Source directory not found:\n{source_dir}")
        return False

    try:
        # Copy and overwrite files
        for file_name in os.listdir(source_dir):
            src_file = os.path.join(source_dir, file_name)
            if os.path.isfile(src_file):
                dst_file = os.path.join(BASE_DIR, file_name)
                shutil.copy2(src_file, dst_file)
        return True
    except Exception as e:
        messagebox.showerror("Error", f"Failed to copy files:\n{str(e)}")
        return False


def main_gui():
    ctypes.windll.shcore.SetProcessDpiAwareness(1)
    root = tk.Tk()
    root.title("Skyrim Resolution Manager")
    root.overrideredirect(True)  # Remove window decorations
    root.attributes("-topmost", True)  # Keep window on top

    # Detect Windows theme
    def get_windows_theme():
        try:
            import winreg
            reg = winreg.ConnectRegistry(None, winreg.HKEY_CURRENT_USER)
            key = winreg.OpenKey(reg, r"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")
            value, _ = winreg.QueryValueEx(key, "AppsUseLightTheme")
            return "light" if value == 1 else "dark"
        except:
            return "light"  # Fallback to light theme

    # Set colors based on theme
    theme = get_windows_theme()
    colors = {
        "dark": {
            "bg": "#2D2D2D",
            "fg": "#FFFFFF",
            "button_bg": "#3D3D3D",
            "button_hover": "#4D4D4D",
            "status_bg": "#1F1F1F"
        },
        "light": {
            "bg": "white",
            "fg": "#333333",
            "button_bg": "#e7ebee",
            "button_hover": "#d3d6d9",
            "status_bg": "#f0f0f0"
        }
    }[theme]

    root.configure(bg=colors["bg"])

    # Window size and centering (keep your original geometry code)
    win_width = 525
    win_height = 225
    root.geometry(f"{win_width}x{win_height}+{(root.winfo_screenwidth() - win_width)//2}+{(root.winfo_screenheight() - win_height)//2}")

    def handle_selection(selection):
        """Process resolution selection"""
        current = get_current_resolution()

        if current == selection:
            root.destroy()
            return

        if copy_ini_files(selection) and set_current_resolution(selection):
            root.destroy()
        else:
            root.destroy()

    # Close button (theme-adjusted)
    close_btn = tk.Button(root, text="✕", font=("Arial", 15,"bold"),
                        command=root.destroy, bd=0, activebackground=colors["bg"],
                          bg=colors["bg"], fg="#888" if theme == "light" else "#666",
                        activeforeground="red", relief="flat")
    close_btn.place(x=win_width-3, y=3, width=25, height=25, anchor = "ne")
    close_btn.bind("<Enter>", lambda e: close_btn.config(fg="red"))
    close_btn.bind("<Leave>", lambda e: close_btn.config(fg="#888" if theme == "light" else "#666"))

    # Title (theme-adjusted)
    title_label = tk.Label(root, text="Choose Skyrim Resolution",
                         font=("Arial", 16, "bold"),
                         bg=colors["bg"], fg=colors["fg"])
    title_label.place(relx=0.5, rely=0.15, anchor="n")

    # Resolution buttons (theme-adjusted)
    btn_frame = tk.Frame(root, bg=colors["bg"])
    btn_frame.place(relx=0.5, rely=0.55, anchor="center")
    resolutions = ["2560x1440", "1920x1080"]
    current_res = get_current_resolution() or "Not set"

    for res in resolutions:
        btn = tk.Button(btn_frame, text=res, width=18, height=2,
                      font=("Arial", 12, "bold"), relief="flat",
                      bg=colors["button_bg"], fg=colors["fg"],
                      activebackground=colors["button_bg"],
                      activeforeground=colors["fg"])

        btn.bind("<Enter>", lambda e, b=btn: b.config(bg=colors["button_hover"]))
        btn.bind("<Leave>", lambda e, b=btn: b.config(bg=colors["button_bg"]))
        btn.config(command=lambda r=res: handle_selection(r))
        btn.pack(side="left", padx=8, pady=8)

    # Status bar (theme-adjusted)
    status_frame = tk.Frame(root, bg=colors["status_bg"], height=32)
    status_frame.pack(side="bottom", fill="x")
    tk.Label(status_frame, text=f"Current Resolution: {current_res}",
           font=("Arial", 10), bg=colors["status_bg"], fg=colors["fg"]).pack(pady=6)

    root.mainloop()





if __name__ == "__main__":
    # Create tracker file if it doesn't exist
    if not os.path.exists(TRACKER_FILE):
        try:
            with open(TRACKER_FILE, 'w') as f:
                f.write("unknown")
        except Exception as e:
            messagebox.showerror("Critical Error", f"Could not initialize tracker file:\n{str(e)}")
            exit(1)

    main_gui()