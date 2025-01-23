
#include "process.cu"

extern "C" {
    bool cudaGrayScaleImage(double *y, int y_h, int y_w, double *x, int x_h, int x_w, int x_d) {
        return _cudaGrayScaleImage(y, y_h, y_w, x, x_h, x_w, x_d);
    }
    bool grayScaleImage(double *y, int y_h, int y_w, double *x, int x_h, int x_w, int x_d) {
        cout << "Y(height: " << y_h << ", width: " << y_w << endl;
        cout << "X(height: " << x_h << ", width: " << x_w << ", depth: " << x_d << endl << endl;

        int d_w = 20;
        int d_h = 20;
        d_w = y_w;
        d_h = y_h;

        for (int i = 0; i < d_h; i++) {
            for (int j = 0; j < d_w; j++) {
                y[idx2(i, j, y_w)] = 0.2989 * x[idx3(i, j, 0, x_h, x_w)] + 0.5870 * x[idx3(i, j, 1, x_h, x_w)] + 0.1140 * x[idx3(i, j, 2, x_h, x_w)];
            }
        }

        return true;
    }
    int cppSum(double *a, int h, int w, int d) {
    
        double sum=0.0;
    
        for (int i = 0; i < h; i++)
        {
            for (int j = 0; j < w; j++)
            {
                for (int k = 0; k < d; k++)
                {
                    sum += 1; // a[i][j][k];
                }
            }
        }
        return sum;    
    }
}