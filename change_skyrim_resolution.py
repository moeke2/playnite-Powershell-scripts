import tkinter as tk
from tkinter import messagebox


def update_resolution(width, height):
    """Update the config file with new resolution values"""
    file_path = r"D:\Games\Nordic Souls\profiles\Nordic Souls\SkyrimPrefs.ini"

    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()
    except Exception as e:
        messagebox.showerror("Error", f"Failed to read config file:\n{str(e)}")
        return False

    found_w, found_h = False, False
    new_lines = []

    for line in lines:
        if line.startswith('iSize W = '):
            new_lines.append(f'iSize W = {width}\n')
            found_w = True
        elif line.startswith('iSize H = '):
            new_lines.append(f'iSize H = {height}\n')
            found_h = True
        else:
            new_lines.append(line)

    if not (found_w and found_h):
        messagebox.showerror("Error", "Resolution settings not found in config file")
        return False

    try:
        with open(file_path, 'w') as file:
            file.writelines(new_lines)
        return True
    except Exception as e:
        messagebox.showerror("Error", f"Failed to write config file:\n{str(e)}")
        return False


def main():
    """Main application entry point"""
    root = tk.Tk()
    root.title("Skyrim Resolution Selector")

    # Window dimensions
    window_width = 300
    window_height = 150

    # Center the window
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    x = (screen_width - window_width) // 2
    y = (screen_height - window_height) // 2
    root.geometry(f"{window_width}x{window_height}+{x}+{y}")
    root.resizable(False, False)

    def on_resolution_select():
        """Handle resolution selection and update config"""
        selection = res_var.get()
        resolutions = {
            "1080p": (1920, 1080),
            "1440p": (2560, 1440)
        }
        width, height = resolutions[selection]

        if update_resolution(width, height):
            # Success - close silently
            root.destroy()
        else:
            # Error message already shown, close window
            root.destroy()

    # GUI components
    res_var = tk.StringVar(value="1080p")

    tk.Label(root, text="Choose your resolution:").pack(pady=10)
    tk.Radiobutton(root, text="1920x1080 (Full HD)", variable=res_var, value="1080p").pack(anchor='w')
    tk.Radiobutton(root, text="2560x1440 (QHD)", variable=res_var, value="1440p").pack(anchor='w')
    tk.Button(root, text="Apply", command=on_resolution_select).pack(pady=10)

    root.mainloop()


if __name__ == "__main__":
    main()