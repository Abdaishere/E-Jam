import java.io.IOException;
import java.io.PipedReader;
import java.io.PipedWriter;
import java.util.ArrayList;

public class Main {
    public static final int N = (int)1e5;

    public static void main(String[] args) throws IOException {
        long start = System.currentTimeMillis();


        PipedReader reader = new PipedReader();
        PipedWriter writer = new PipedWriter(reader);

        for (int i = 0; i < N; i++) {
            writer.write("a".repeat(10));
        }
        writer.write('\n');

        int i;
        while ((char)(i = reader.read()) != '\n') {
//            System.out.print((char)i);
        }

        writer.close();
        reader.close();

        long end = System.currentTimeMillis();
        long elapsedTime = end - start;
        System.out.println("Total time = " + elapsedTime);
    }
}