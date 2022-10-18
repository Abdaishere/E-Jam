import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    public static final int PORT = 5000;

    public Server(int port) throws IOException {

        // set timer for 5 min
        long counter = 0;

        long startTest = System.currentTimeMillis();
        long endTest = System.currentTimeMillis();

        // create a ServerSocket to listen for connection with client
        ServerSocket serverSocket = new ServerSocket(port);

        // accepting connection from client
        Socket socket = serverSocket.accept();

        // create a stream for reading from this socket
        BufferedReader fromClient = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        // create a stream for writing to this socket
        PrintStream printStream = new PrintStream(socket.getOutputStream());

        String response = "b".repeat(10), request;

        // receive request from the client
        while ((request = fromClient.readLine()) != null) {
//            System.out.println("Client requested: " + request);

            // send response to the client
            printStream.println(response);

            counter++;
            endTest = System.currentTimeMillis();
        }

        fromClient.close();
        printStream.close();
        socket.close();

        long elapsedTime = endTest - startTest;
        System.out.println("Total time = " + elapsedTime);
        System.out.println("Sent responses = " + counter);
    }

    public static void main(String[] args) throws IOException {
        new Server(PORT);
    }
}