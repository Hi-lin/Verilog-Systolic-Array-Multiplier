#include <windows.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

uint8_t* genArray(){
        uint8_t* arr = (uint8_t*)malloc(16 * sizeof(uint8_t));
        for(int i = 0; i<16; i++){
            arr[i] = rand() % 256;
        }
        return arr;
    }

int main() {
    HANDLE h =
        CreateFile(
            "\\\\.\\COM3",
            GENERIC_READ | GENERIC_WRITE,
            0,
            NULL,
            OPEN_EXISTING,
            0,
            NULL
        );

    if (h == INVALID_HANDLE_VALUE) {
        printf("Failed to open\n");
        return 1;
    }

    DCB dcb = {0};

    dcb.DCBlength = sizeof(dcb);

    GetCommState(h, &dcb);

    dcb.BaudRate = CBR_9600;
    dcb.ByteSize = 8;
    dcb.StopBits = ONESTOPBIT;
    dcb.Parity = NOPARITY;

    SetCommState(h, &dcb);

    COMMTIMEOUTS timeouts = {0};

    timeouts.ReadIntervalTimeout = 0;
    timeouts.ReadTotalTimeoutMultiplier = 0;
    timeouts.ReadTotalTimeoutConstant = 0;

    SetCommTimeouts(h, &timeouts);
    
    DWORD written;

    //char msg[] = "Hello UART\n";
    //  char msg1[] = {0};
    //  WriteFile(
    //     h,
    //     msg1,
    //     sizeof(msg1),
    //     &written,
    //     NULL
    // );
 uint8_t buffer[256];
    DWORD read;
    read = 0;
    // printf("step0\n");
    //     ReadFile(
    //     h,
    //     buffer,
    //     1,
    //     &read,
    //     NULL
    // );
    //   uint8_t msg2[] = {
    //       1,2,3,4,
    //       5,6,7,8,
    //       9,10,11,12,
    //       13,14,15,16};
    //     // uint8_t msg2[] = {
    //     //     1,1,1,1,
    //     //     1,1,1,1,
    //     //     1,1,1,1,
    //     //     1,1,1,1,
    //     // };
    // WriteFile(
    //     h,
    //     msg2,
    //     sizeof(msg2),
    //     &written,
    //     NULL
    // );
    // read = 0;
    // printf("step1\n %d %d", buffer[0], read);
    //     ReadFile(
    //     h,
    //     buffer,
    //     1,
    //     &read,
    //     NULL
    // );
    // uint8_t msg3[] = {
    //     //   1,1,1,1,
    //     //   1,1,1,1,
    //     //     1,1,1,1,
    //     //     1,1,1,1,
    //       1,2,3,4,
    //       5,6,7,8,
    //       9,10,11,12,
    //       13,14,15,16
    //     };
    // WriteFile(
    //     h,
    //     msg3,
    //     sizeof(msg3),
    //     &written,
    //     NULL
    // );
    // printf("step2 %d %d\n", buffer[0], read);
    // read = 0;
    //     ReadFile(
    //     h,
    //     buffer,
    //     1,
    //     &read,
    //     NULL
    // );
    // printf("%d", buffer[0]);

    // uint8_t x = 0;
    // for(; x<4; x++){
    //     for(uint8_t y = 0; y<4; y++){
    //         uint8_t value = x<<3 | y<<1 | 1;
    //         uint8_t msg4[] = {value};
    //         WriteFile(
    //             h,
    //             msg4,
    //             sizeof(msg4),
    //             &written,
    //             NULL
    //         );
    //             DWORD read;
    //             ReadFile(
    //             h,
    //             buffer,
    //             5,
    //             &read,
    //             NULL
    //             );
    //             uint32_t ans =
    //                 ((uint32_t)buffer[1] << 24) |
    //                 ((uint32_t)buffer[2] << 16) |
    //                 ((uint32_t)buffer[3] << 8)  |
    //                 ((uint32_t)buffer[4]);
    //         // uint32_t ans = buffer[1]<<24 | buffer[2]<<16 | buffer[3]<<8 | buffer[4];
    //         printf("%d %d %d %d %lu\n", buffer[1], buffer[2], buffer[3], buffer[4], ans);
    //     }
    // }
    //     printf("\n");
        uint8_t msgnew = {
            0b11111111
        };
        for(int i = 0; i<50; i++){
            WriteFile(
                h,
                &msgnew,
                sizeof(msgnew),
                &written,
                NULL
            );
            ReadFile(
                h,
                buffer,
                1,
                &read,
                NULL
            ); //clear
            uint8_t msg1 = {0};
            WriteFile(
                h,
                &msg1,
                sizeof(msg1),
                &written,
                NULL
            );
            ReadFile(
                h,
                buffer,
                1,
                &read,
                NULL
            ); 
             uint8_t* a = genArray();
             uint8_t* b = genArray();
            // printf("%d", a[0]);
            // printf("%d", b[0]);
            // uint8_t a[] = {
            //     1,2,3,4,
            //     5,6,7,8,
            //     9,10,11,12,
            //     13,14,15,16
            // };
            // uint8_t b[] = {
            //     1,2,3,4,
            //     5,6,7,8,
            //     9,10,11,12,
            //     13,14,15,16
            // };
            WriteFile(
                h,
                a,
                16,
                &written,
                NULL
            ); 
            ReadFile(
                h,
                buffer,
                1,
                &read,
                NULL
            );
            WriteFile(
                h,
                b,
                16,
                &written,
                NULL
            );
            ReadFile(
                h,
                buffer,
                1,
                &read,
                NULL
            );
            uint32_t ans[4][4];

             for(int x = 0; x<4; x++){
                 for(int y = 0; y<4; y++){
                     ans[x][y] = 0;
                     for(int k = 0; k<4; k++){
                         ans[x][y] += ((uint8_t)a[y*4+k]) * ((uint8_t)b[k*4+x]);
                        //   if(x ==0&&y==0)
                        //   printf("%d %d %d \n", ans[x][y], a[y*4+k], b[k*4+x]);
                     }
                 }
            }
            // ReadFile(
            //             h,
            //             buffer,
            //             4,
            //             &read,
            //             NULL
            //         );
            uint8_t works = 1;
            for(int x = 0; x<4; x++){
                for(int y = 0; y<4; y++){
                    uint32_t ans1;
                    uint8_t value = x<<3 | y<<1 | 1;
                    uint8_t msg2[] = {value};
                    WriteFile(
                        h,
                        msg2,
                        sizeof(msg2),
                        &written,
                        NULL
                    );
                    ReadFile(
                        h,
                        buffer,
                        1,
                        &read,
                        NULL
                    );

                    ReadFile(
                        h,
                        buffer,
                        4,
                        &read,
                        NULL
                    );
                    ans1 =
                        ((uint32_t)buffer[0] << 24) |
                        ((uint32_t)buffer[1] << 16) |
                        ((uint32_t)buffer[2] << 8)  |
                        ((uint32_t)buffer[3]);
                    if(ans1 != ans[x][y]){
                        works = 0;
                        printf("Failed at %d %d: %d %d %d %d %d != %lu\n", x, y, buffer[0], buffer[1], buffer[2], buffer[3], ans1, ans[x][y]);
                        for(int y1 = 0; y1<4; y1++){
                            for(int x1 = 0; x1<4; x1++){
                                printf("%d ", a[y1*4+x1]);
                            }
                            printf("\n");
                        }
                        for(int y1 = 0; y1<4; y1++){
                            for(int x1 = 0; x1<4; x1++){
                                printf("%d ", b[y1*4+x1]);
                            }
                            printf("\n");

                        }
                        break;
                    }
                }
                if(works ==0) break;
            }
            if(works){
                printf("Success\n");
            }
            free(a);
            free(b);
       }

    
    // uint8_t msg2[] = {

        
    // };
    // WriteFile(
    //     h,
    //     msg2,
    //     sizeof(msg2),
    //     &written,
    //     NULL
    // );

    CloseHandle(h);

    return 0;
}
