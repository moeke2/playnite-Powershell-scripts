import os
import shutil
import tkinter as tk
from tkinter import messagebox
import ctypes

# Configuration
BASE_DIR = r"D:\Games\Nordic Souls\profiles\Nordic Souls"
INI_SWAP_DIR = os.path.join(BASE_DIR, "INI swap")
TRACKER_FILE = os.path.join(INI_SWAP_DIR, "current_resolution.txt")
ALLOWED_RESOLUTIONS = ("1920x1080", "2560x1440")
RESOLUTION_FOLDERS = {res: os.path.join(INI_SWAP_DIR, res) for res in ALLOWED_RESOLUTIONS}

def show_success_message(resolution: str) -> None:
    def get_windows_theme():
        try:
            import winreg
            reg = winreg.ConnectRegistry(None, winreg.HKEY_CURRENT_USER)
            key = winreg.OpenKey(reg, r"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")
            value, _ = winreg.QueryValueEx(key, "AppsUseLightTheme")
            return "light" if value == 1 else "dark"
        except:
            return "light"  # Fallback to light theme

    theme = get_windows_theme()
    if theme == "dark":
        bg_color = "#2e2e2e"  # Dark gray background
        text_color = "#ffffff"  # White main text
        subtext_color = "#cccccc"  # Light gray secondary text
        accent_color = "#9B59B6"  # A nice blue accent
        accent_click = "#8E44AD"  # Darker blue for clicks
        close_fg = "#bbbbbb"  # Light gray for the close button
        close_fg_hover = "#ff6b6b"  # Soft red when hovering the close button
    else:
        bg_color = "#f0f0f0"
        text_color = "#333333"
        subtext_color = "#555555"
        accent_color = "#6495ED"
        accent_click = "#417dc1"
        close_fg = "#888888"
        close_fg_hover = "#ff746c"

    ctypes.windll.shcore.SetProcessDpiAwareness(1)

    root = tk.Tk()
    root.title("Swapped ini files!")
    root.overrideredirect(True)  # Remove window decorations
    root.attributes("-topmost", True)  # Keep window on top
    root.configure(bg=bg_color)

    win_width = 500
    win_height = 200

    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    x = (screen_width - win_width) // 2
    y = (screen_height - win_height) // 2
    root.geometry(f"{win_width}x{win_height}+{x}+{y}")



    close_btn = tk.Button(root, text="✕", font=("Arial", 14, "bold"),
                          command=root.destroy, bd=0,
                          fg=close_fg, bg=bg_color, activebackground=bg_color,
                          activeforeground=close_fg_hover, relief="flat")
    close_btn.place(x=win_width - 1, y=1, width=24, height=24, anchor="ne")
    close_btn.bind("<Enter>", lambda e: close_btn.config(fg=close_fg_hover))
    close_btn.bind("<Leave>", lambda e: close_btn.config(fg=close_fg))

    main_frame = tk.Frame(root, bg=bg_color)
    main_frame.place(relx=0.5, rely=0.5, anchor="center", relwidth=0.95, relheight=0.95)
    close_btn.lift()  # Ensure the close button remains on top

    label_title = tk.Label(main_frame, text="INI files have been swapped!",
                           font=("Arial", 17, "bold"), bg=bg_color, fg=text_color)
    label_title.pack(pady=(10, 10), fill="x", padx=10)

    label_resolution = tk.Label(main_frame,
                                text=f"Resolution has been changed to {resolution}",
                                font=("Arial", 13), bg=bg_color, fg=subtext_color)
    label_resolution.pack(pady=(0, 15), fill="x", padx=10)

    ok_btn = tk.Button(main_frame, text="OK", font=("Arial", 16),
                       command=root.destroy, bd=0, relief="flat",
                       bg=accent_color, fg="white",
                       activebackground=accent_click, activeforeground="white")
    ok_btn.place(anchor="s", relx=0.5, rely=0.9, width=100, height=60)

    ok_btn.bind("<Enter>", lambda e:ok_btn.config(relief="raised", bd=2))
    ok_btn.bind("<Leave>", lambda e:ok_btn.config(relief="flat", bd=0))

    root.after(3000, root.destroy)
    root.mainloop()

def get_current_resolution() -> str:
    hdc = ctypes.windll.user32.GetDC(0)
    try:
        return f"{ctypes.windll.gdi32.GetDeviceCaps(hdc, 118)}x{ctypes.windll.gdi32.GetDeviceCaps(hdc, 117)}"
    finally:
        ctypes.windll.user32.ReleaseDC(0, hdc)


def read_stored_resolution() -> str:
    try:
        with open(TRACKER_FILE, 'r') as f:
            return f.read().strip() or "not set"
    except FileNotFoundError:
        os.makedirs(os.path.dirname(TRACKER_FILE), exist_ok=True)
        open(TRACKER_FILE, 'a').close()
        return "not set"
    except Exception as e:
        messagebox.showerror("Error", f"Failed to read tracker file:\n{str(e)}")
        raise RuntimeError(f"Tracker file read error: {e}")


def update_resolution_file(new_res: str) -> None:
    try:
        with open(TRACKER_FILE, 'w') as f:
            f.write(new_res)
    except Exception as e:
        messagebox.showerror("Error", f"Failed to update tracker file:\n{str(e)}")
        raise RuntimeError(f"Tracker file update error: {e}")


def copy_ini_files(resolution: str) -> None:
    source_dir = RESOLUTION_FOLDERS.get(resolution)
    if not source_dir or not os.path.exists(source_dir):
        messagebox.showerror("Error", f"Source directory not found:\n{source_dir}")
        raise FileNotFoundError(f"Missing source directory: {source_dir}")

    try:
        for filename in os.listdir(source_dir):
            src = os.path.join(source_dir, filename)
            if os.path.isfile(src):
                shutil.copy2(src, BASE_DIR)
    except Exception as e:
        messagebox.showerror("Error", f"File copy failed:\n{str(e)}")
        raise RuntimeError(f"File copy error: {e}")


def main():
    current_res = get_current_resolution()

    if current_res not in ALLOWED_RESOLUTIONS:
        messagebox.showerror(
            "Unsupported Resolution",
            f"Resolution {current_res} not supported\n"
            f"Supported resolutions: {', '.join(ALLOWED_RESOLUTIONS)}"
        )
        raise ValueError(f"Unsupported resolution: {current_res}")

    if read_stored_resolution() != current_res:
        update_resolution_file(current_res)
        copy_ini_files(current_res)
        show_success_message(current_res)


if __name__ == "__main__":
    main()
