import sys
import ctypes
import pygetwindow as gw
import pyautogui
import time
import os
import psutil


DELAY = 2


def get_window(win_title):
    hwnd = ctypes.windll.user32.FindWindowW(None, win_title)
    if hwnd:
        return gw.Window(hwnd)
    return None

def bring_window_to_foreground(win):
    if win:
        win.restore()
        win.maximize()
        try: win.activate()
        except: print("window already activated")
    else:
        print("No valid window object provided.")


def wait_for_process_to_close(process_name, timeout=4):
    """Wait for a specific process to terminate, with a timeout."""
    start_time = time.time()
    while any(p.name().lower() == process_name.lower() for p in psutil.process_iter(['name'])):
        elapsed_time = time.time() - start_time
        if elapsed_time >= timeout:
            return False
        time.sleep(0.3)
        print(f"{elapsed_time}")
    return True


def click_image(image_path):
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Image path does not exist: {image_path}")

    try:
        time.sleep(DELAY)
        location = pyautogui.locateCenterOnScreen(image_path, grayscale=True, confidence=0.8)
        initial_position = pyautogui.position()
        pyautogui.click(location)
        pyautogui.click(location)
        pyautogui.moveTo(initial_position)
        print("image found")
        return True
    except pyautogui.ImageNotFoundException:
        print("Image not found")
    return False

def close_window(win):
    if win:
        try:
            win.close()
        except Exception as e:
            print(f"Error closing window: {e}")
    else:
        print("No valid window object provided.")

if __name__ == '__main__':
    if len(sys.argv) > 1:
        try:
            DELAY = float(sys.argv[1])
        except ValueError:
            print("Invalid delay value. Using default delay.")

    window_title = "Proton VPN"
    image_path = r"C:\Users\jonas\OneDrive\Scripts\proton disconnect.png"

    window = get_window(window_title)
    if window:
        bring_window_to_foreground(window)
        click_image(image_path)
        if not wait_for_process_to_close("ProtonVPN.WireGuardService.exe"):
            print("Retrying...")
            DELAY *= 4
            window = get_window(window_title)
            bring_window_to_foreground(window)
            click_image(image_path)
            if not wait_for_process_to_close("ProtonVPN.WireGuardService.exe"):
                exit()

        close_window(window)
