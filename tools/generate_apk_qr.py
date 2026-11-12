import qrcode
import os

url = "http://10.19.117.171:8080/SectorZero-Lockdown-debug.apk"
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_M,
    box_size=10,
    border=4,
)
qr.add_data(url)
qr.make(fit=True)

img = qr.make_image(fill_color="black", back_color="white")
os.makedirs("/home/am/targetkill/build", exist_ok=True)
img.save("/home/am/targetkill/build/apk_qr.png")

artifact_path = "/home/am/.gemini/antigravity-cli/brain/ed4389b5-30c4-4b6e-ad33-24ea6332cbe1/apk_qr.png"
img.save(artifact_path)
print(f"QR Code successfully saved for {url}")
