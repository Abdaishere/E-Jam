# IPC Benchmark

## Sockets in Java
#### N = 1e5:
Server: 3338 ms 
Client: 3346 ms

#### N = 1e6

Server: 28825 ms
Client: 28825 ms

#### N = 1e7

Server: 207555 ms
Client: 207554 ms

## Sockets in C++

#### N = 1e5

Server: 1276 ms 
Client: 1274 ms

#### N = 1e6

Server: 13594 ms
Client: 13594 ms

#### N = 1e7

Server: 157395 ms
Client: 157434 ms

## Pipes in Java

#### N = 1e5

Main: 8 ms 

#### N = 1e6

Main: 12 ms

#### N = 1e7

Main: 12 ms

## Pipes in C++

#### N = 1e5

Server: 945 ms 
Client: 636 ms

#### N = 1e6

Server: 7711 ms
Client: 7468 ms

#### N = 1e7

Server: 155952 ms
Client: 155662 ms

## Posix (shared memory) in Java

#### N = 1e5

Server: 27 ms 
Client: 57 ms

#### N = 1e6

Server: 52 ms
Client: 220 ms

#### N = 1e7

Server: 190 ms
Client: 1028 ms

## Posix (shared memory) in C++

#### N = 1e5

Server: 15 ms
Client: 15 ms

#### N = 1e6

Server: 116 ms
Client: 115 ms

#### N = 1e7

Server: 1709 ms
Client: 1708 ms


### The conclusion:
As we can see, (posix in c++) is the fastest method.
