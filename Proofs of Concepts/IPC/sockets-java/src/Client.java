import java.io.*;
import java.net.Socket;
import java.util.ArrayList;

public class Client {
    public static final String IP = "127.0.0.1";
    public static final int PORT = 5000;
    public static final int N = (int)1e5;

    public Client(String ip, int port) throws IOException {
        ArrayList<String> requests = new ArrayList<>();
        for (int i = 1; i <= N; i++) {
            requests.add("a".repeat(10));
        }

        long start = System.currentTimeMillis();

        // create a socket to communicate to the specified host and port
        Socket socket = new Socket(ip, port);

        // create a stream for reading from this socket
        BufferedReader fromServer = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        // create a stream for writing to this socket
        PrintStream printStream = new PrintStream(socket.getOutputStream());

        String responce;
        for (String request : requests) {
            // send request to the server
            printStream.println(request);

            // receive response from the server
            responce = fromServer.readLine();
//            System.out.println("Server responded: " + responce);
        }

        fromServer.close();
        printStream.close();
        socket.close();

        long end = System.currentTimeMillis();
        long elapsedTime = end - start;
        System.out.println("Total time = " + elapsedTime);
    }

    public static void main(String[] args) throws IOException {
        new Client(IP, PORT);
    }
}