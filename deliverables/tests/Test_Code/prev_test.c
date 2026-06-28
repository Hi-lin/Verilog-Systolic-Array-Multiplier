#include <windows.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

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
     char msg1[] = {0};
     WriteFile(
        h,
        msg1,
        sizeof(msg1),
        &written,
        NULL
    );
 uint8_t buffer[256];
    DWORD read;
    read = 0;
    printf("step0\n");
        ReadFile(
        h,
        buffer,
        1,
        &read,
        NULL
    );
      uint8_t msg2[] = {
          1,2,3,4,
          5,6,7,8,
          9,10,11,12,
          13,14,15,16};
        // uint8_t msg2[] = {
        //     1,1,1,1,
        //     1,1,1,1,
        //     1,1,1,1,
        //     1,1,1,1,
        // };
    WriteFile(
        h,
        msg2,
        sizeof(msg2),
        &written,
        NULL
    );
    read = 0;
    printf("step1\n %d %d", buffer[0], read);
        ReadFile(
        h,
        buffer,
        1,
        &read,
        NULL
    );
    uint8_t msg3[] = {
        //   1,1,1,1,
        //   1,1,1,1,
        //     1,1,1,1,
        //     1,1,1,1,
          1,2,3,4,
          5,6,7,8,
          9,10,11,12,
          13,14,15,16
        };
    WriteFile(
        h,
        msg3,
        sizeof(msg3),
        &written,
        NULL
    );
    printf("step2 %d %d\n", buffer[0], read);
    read = 0;
        ReadFile(
        h,
        buffer,
        1,
        &read,
        NULL
    );
    printf("%d", buffer[0]);

    uint8_t x = 0;
    for(; x<4; x++){
        for(uint8_t y = 0; y<4; y++){
            uint8_t value = x<<3 | y<<1 | 1;
            uint8_t msg4[] = {value};
            WriteFile(
                h,
                msg4,
                sizeof(msg4),
                &written,
                NULL
            );
                DWORD read;
                ReadFile(
                h,
                buffer,
                5,
                &read,
                NULL
                );
                uint32_t ans =
                    ((uint32_t)buffer[1] << 24) |
                    ((uint32_t)buffer[2] << 16) |
                    ((uint32_t)buffer[3] << 8)  |
                    ((uint32_t)buffer[4]);
            // uint32_t ans = buffer[1]<<24 | buffer[2]<<16 | buffer[3]<<8 | buffer[4];
            printf("%d %d %d %d %lu\n", buffer[1], buffer[2], buffer[3], buffer[4], ans);
        }
        printf("\n");
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