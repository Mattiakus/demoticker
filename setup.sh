echo "downloading java"

wget https://download.bell-sw.com/java/21.0.6+10/bellsoft-jdk21.0.6+10-linux-aarch64.deb
apt install ./bellsoft-jdk21.0.6+10-linux-aarch64.deb
rm https://download.bell-sw.com/java/21.0.6+10/bellsoft-jdk21.0.6+10-linux-aarch64.deb

echo "downloading signal lib"
wget https://github.com/exquo/signal-libs-build/releases/download/libsignal_v0.66.1/libsignal_jni.so-v0.66.1-aarch64-unknown-linux-gnu.tar.gz
tar -xf libsignal_jni.so
rm libsignal_jni.so-v0.66.1-aarch64-unknown-linux-gnu.tar.gz
mv libsignal_jni.so usr/lib/

echo "downloading signal-cli"
export VERSION=<latest version, format "0.13.12">
wget https://github.com/AsamK/signal-cli/releases/download/v"${VERSION}"/signal-cli-"${VERSION}".tar.gz
sudo tar xf signal-cli-"${VERSION}".tar.gz -C /opt
sudo ln -sf /opt/signal-cli-"${VERSION}"/bin/signal-cli /usr/local/bin/
