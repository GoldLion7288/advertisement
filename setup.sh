#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Step 1: Update system packages..."
sudo apt update

echo "📦 Step 2: Install Python 3, pip, and venv..."
sudo apt install -y python3 python3-pip python3-venv

echo ""
echo "🐍 Step 3: Creating virtual environment..."
# Ensure current directory is writable by the current user
sudo chown -R $USER:$USER "$(pwd)"

# Remove any existing venv to avoid permission conflicts
rm -rf venv

# Create virtual environment with system site packages
python3 -m venv --system-site-packages venv
echo "✓ Virtual environment created at ./venv"
echo ""

echo "📚 Step 4: Installing system dependencies..."
echo "   → Installing PyQt5 system packages..."
sudo apt install -y python3-pyqt5 pyqt5-dev-tools

echo "   → Installing OpenCV system dependencies..."
sudo apt install -y libgl1-mesa-glx libglib2.0-0 \
                    libavcodec-extra libavformat-dev libswscale-dev

echo "   → Installing FFmpeg libraries for audio-video sync..."
sudo apt install -y ffmpeg libavutil-dev libavcodec-dev libavformat-dev \
                    libswresample-dev libavfilter-dev libavdevice-dev \
                    libsdl2-dev libsdl2-mixer-2.0-0

echo "   → Installing X11 libraries for Qt GUI..."
sudo apt install -y libxcb-xinerama0 libx11-xcb1 libxkbcommon-x11-0 libxcb-icccm4 \
                    libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 \
                    libxcb-shape0 libxcb-sync1 libxcb-xfixes0 libxrender1

echo "   → Installing Qt5 core libraries..."
sudo apt install -y libqt5gui5 libqt5core5a libqt5widgets5 libqt5opengl5 \
                    libqt5x11extras5 libqt5dbus5 libqt5network5

echo ""
echo "⚡ Step 5: Setting up Python environment..."
source venv/bin/activate

echo "   → Upgrading pip..."
pip install --upgrade pip

echo "   → Replacing OpenCV with headless version..."
pip uninstall -y opencv-python || true
pip install opencv-python-headless==4.12.0.88

echo "   → Installing remaining Python requirements..."
pip install -r requirements.txt

echo ""
echo "✅ Setup complete! Virtual environment is ready at ./venv"
