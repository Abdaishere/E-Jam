import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

public class Server {
    public static final int PORT = 5000;

    public static final int N = (int)1e5;

    public Server(int port) throws IOException {
        ArrayList<String> responses = new ArrayList<>();
        for (int i = 1; i <= N; i++) {
            responses.add("b".repeat(10));
        }

        long start = System.currentTimeMillis();

        // create a ServerSocket to listen for connection with client
        ServerSocket serverSocket = new ServerSocket(port);

        long end = System.currentTimeMillis();
        long elapsedTime = end - start;

        // accepting connection from client
        Socket socket = serverSocket.accept();

        start = System.currentTimeMillis();

        // create a stream for reading from this socket
        BufferedReader fromClient = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        // create a stream for writing to this socket
        PrintStream printStream = new PrintStream(socket.getOutputStream());

        String request;
        for (String response : responses) {
            // receive request from the client
            request = fromClient.readLine();
//            System.out.println("Client requested: " + request);

            // send response to the client
            printStream.println(response);
        }

        fromClient.close();
        printStream.close();
        socket.close();

        end = System.currentTimeMillis();
        elapsedTime += end - start;
        System.out.println("Total time = " + elapsedTime);
    }

    public static void main(String[] args) throws IOException {
        new Server(PORT);
    }
}