import subprocess
import ctypes
import os

import numpy as np


class MissingBinaryException(Exception):
    pass

class CompileFailedException(Exception):
    pass


class Cpp(ctypes.CDLL):

    def __init__(self, compile_file: str=None, library_file: str=None, library_file_prefix: str='./') -> None:

        compile_exit_status = subprocess.run(["bash", compile_file]).returncode
        if compile_exit_status != 0:
            raise CompileFailedException(f"{compile_file} failed")

        name=f'{library_file_prefix}/{library_file}'
        if not os.path.exists(name):
            raise MissingBinaryException(f"Binary({name}) was not found")

        super().__init__(name=name)
    
    @staticmethod
    def toString(x: str):
        return ctypes.create_string_buffer(bytes(x, encoding='utf-8'))


class ProcessCpp(Cpp):
    def __init__(self) -> None:
        super().__init__(compile_file="compileprocess.sh", library_file="libprocess.so", library_file_prefix='./out')


process = ProcessCpp()


def processImage(input_file: str=None, output_file: str=None) -> bool:
    return bool( process.processImage(Cpp.toString(input_file), Cpp.toString(output_file)) )


def processImageNumpy(y: np.ndarray, x: np.ndarray):
    """ Takes a numpy array, in order to pass the reference to the C++ program"""
    print(y.shape, x.shape)
    

    # return bool(process.processImageNumpy(c_y, c_x))


def grayScaleImage(y: np.ndarray, x: np.ndarray):
    print("1 shapes: ", y.shape, x.shape)

    y_shape, x_shape =  y.shape, x.shape
    # y = y.reshape(1, -1)
    # x = x.reshape(1, -1)
    y = y.flatten()
    x = x.flatten()

    c_y = y.ctypes.data_as(ctypes.POINTER(ctypes.c_double))
    c_x = x.ctypes.data_as(ctypes.POINTER(ctypes.c_double))

    print(f"New Shapes: Y{y.shape}, X{x.shape}")

    processed = process.grayScaleImage(c_y, y_shape[0], y_shape[1], c_x, x_shape[0], x_shape[1], x_shape[2])
    
    y = y.reshape(y_shape)
    x = x.reshape(x_shape)
    return y, x, processed
    

def cudaGrayScaleImage(y: np.ndarray, x: np.ndarray):
    print("1 shapes: ", y.shape, x.shape)

    y_shape, x_shape =  y.shape, x.shape
    y = y.flatten()
    x = x.flatten()

    c_y = y.ctypes.data_as(ctypes.POINTER(ctypes.c_double))
    c_x = x.ctypes.data_as(ctypes.POINTER(ctypes.c_double))

    print(f"New Shapes: Y{y.shape}, X{x.shape}")

    processed = process.cudaGrayScaleImage(c_y, y_shape[0], y_shape[1], c_x, x_shape[0], x_shape[1], x_shape[2])
    
    y = y.reshape(y_shape)
    x = x.reshape(x_shape)
    return y, x, processed

def cppSum(x: np.ndarray):
    c_x = x.ctypes.data_as(ctypes.POINTER(ctypes.c_double))
    return process.cppSum(c_x, x.shape[0], x.shape[1], x.shape[2])
