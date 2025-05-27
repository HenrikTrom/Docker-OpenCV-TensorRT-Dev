test -e ${OPENCV_VERSION}.zip || wget https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.zip
test -e opencv-${OPENCV_VERSION} || unzip ${OPENCV_VERSION}.zip
test -e opencv_extra_${OPENCV_VERSION}.zip || wget -O opencv_extra_${OPENCV_VERSION}.zip https://github.com/opencv/opencv_contrib/archive/refs/tags/${OPENCV_VERSION}.zip
test -e opencv_contrib-${OPENCV_VERSION} || unzip opencv_extra_${OPENCV_VERSION}.zip

cd opencv-${OPENCV_VERSION}

# Check if the build directory exists
directory="build"
if [ -d "$directory" ]; then
    echo "Found build"
    cd build
else
    echo "Re-building opencv-${OPENCV_VERSION}"
    mkdir build
    cd build

    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_CXX_FLAGS="${CPP_OPTIMIZATIONS}" \
    -D CMAKE_C_FLAGS="${CPP_OPTIMIZATIONS}" \
    -D CMAKE_INSTALL_PREFIX=/usr/local/ \
    -D WITH_TBB=ON \
    -D ENABLE_FAST_MATH=1 \
    -D CUDA_FAST_MATH=1 \
    -D WITH_CUBLAS=1 \
    -D WITH_CUDA=ON \
    -D BUILD_opencv_cudacodec=ON \
    -D WITH_CUDNN=ON \
    -D CUDNN_ROOT=/usr \
    -D OPENCV_DNN_CUDA=ON \
    -D WITH_ARUCO=ON \
    -D WITH_QT=OFF \
    -D WITH_OPENGL=ON \
    -D BUILD_opencv_apps=OFF \
    -D BUILD_opencv_python2=OFF \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_PC_FILE_NAME=opencv.pc \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D CUDA_ARCH_BIN=${CUDA_ARCH_BIN} \
    -D WITH_FFMPEG=ON \
    ..
fi

sudo make -j$(nproc)
sudo make install

cd ../.. && rm ${OPENCV_VERSION}.zip && rm opencv_extra_${OPENCV_VERSION}.zip