from PIL import Image
import numpy as np
import ctypes
import os


from process import cppSum, grayScaleImage, cudaGrayScaleImage

def printMatrix(x, start_y=200, start_x=200, rows=5, cols=4, ks=3, ndim=None):
    if ndim is None:
        ndim = len(x.shape)
    if ndim < 3:
        ks = 1

    print("="*2*cols, f"Python Data: ({cols} X {cols})", "="*2*cols)

    for i in range(start_y, rows+start_y):
        print(i, "[", end="")
        for j in range(start_x, cols+start_x):
            print(j, "[", end="")
            for k in range(ks):
                if ndim == 3:
                    print(int(x[i][j][k]), end=", ")
                elif ndim == 2:
                    print(int(x[i][j]), end="\t")
            print("]\t", end="")
        print("]")
    print()



# imagefile = "resources/cat1.jpg"


# img: Image.Image = Image.open(imagefile)

# data = np.asarray(img, dtype=np.double)  # dtype=np.float64

import cv2
import numpy as np

# Creating a VideoCapture object to read the video
data = cv2.VideoCapture('sample.mp4') 

# Make a Square
# TODO: change to when the height and width change to the height being bigger
remove_from_side = (data.shape[1] - data.shape[0]) // 2
data = data[:, remove_from_side:-remove_from_side-1]


print("Input Shape:\t", data.shape)
print("Pixel 2,2,2:\t", data[2][2][2])
print()


printMatrix(data)

# data[0:256, 0:256] = [255, 0, 0] # red patch in upper left


# Sums test
# true_sum, cpp_sum = np.sum(data), cppSum(data)
# sums_equal = true_sum == cpp_sum
# if not sums_equal:
#     raise ValueError("SUMS DO NOT EQUAL(true_sum: {true_sum}, cpp_sum: {cpp_sum})")
# print(f"true_sum: {true_sum}, cpp_sum: {cpp_sum}, sums_equal: {sums_equal}\n\n")


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# process Image
# data is the 3D array of the input image



_2d_data = np.zeros((data.shape[0], data.shape[1]), dtype=np.double)
printMatrix(_2d_data)

_2d_data, data, processed = grayScaleImage(_2d_data, data)
# _2d_data, data, processed = cudaGrayScaleImage(_2d_data, data)


# retrun the reference to the 2D array
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

printMatrix(data)
printMatrix(_2d_data)

new_img = Image.fromarray(_2d_data.astype(dtype=np.uint8))
new_img.save("./resources/new_cat1.jpg")
