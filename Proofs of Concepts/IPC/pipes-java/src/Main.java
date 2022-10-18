import java.io.IOException;
import java.io.PipedReader;
import java.io.PipedWriter;

public class Main {

    public static void main(String[] args) throws IOException {
        long timer = 5 * 60 * 1000, counter = 0;

        long startTest = System.currentTimeMillis();
        long endTest = System.currentTimeMillis();

        PipedWriter writeToServer = new PipedWriter();
        PipedReader readFromClient = new PipedReader();

        PipedWriter writeToClient = new PipedWriter();
        PipedReader readFromServer = new PipedReader();

        writeToServer.connect(readFromClient);
        writeToClient.connect(readFromServer);

        while (endTest - startTest < timer) {
            writeToServer.write("a".repeat(10).toCharArray());
            writeToServer.write('\n');

            int i;
            while ((char)(i = readFromClient.read()) != '\n') {
//                System.out.print((char)i);
            }

            writeToClient.write("b".repeat(10).toCharArray());
            writeToClient.write('\n');


            while ((char)(i = readFromServer.read()) != '\n') {
//                System.out.print((char)i);
            }

            counter++;
            endTest = System.currentTimeMillis();
        }

        writeToClient.close();
        readFromClient.close();

        long elapsedTime = endTest - startTest;
        System.out.println("Total time = " + elapsedTime);
        System.out.println("Total sent = " + counter);
    }
}

// 331606
// 6747891
