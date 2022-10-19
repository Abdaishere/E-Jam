import Instructions.Instruction;

import java.io.File;
import java.io.FileNotFoundException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.Scanner;
import java.util.concurrent.TimeUnit;

public class Main {

    public static void main(String[] args) throws InterruptedException {
        ArrayList<Instruction> Instructions = new ArrayList<>();

        // Read Instructions from file
        System.out.println("\u001B[46m" + "\u001B[30m" + "====================" + " Parsing Input Instructions " + "====================" + "\u001B[0m");
        System.out.print("\u001B[36m"); // text Color is Cyan
        try {
            File file = new File("Config.txt");
            Scanner myReader = new Scanner(file);
            while (myReader.hasNextLine()) {
                String data = myReader.nextLine();

                try {
                    Instructions.addAll(Parser.Parse(data));
                } catch (Error e) {
                    System.out.println(e);
                }

                System.out.println("\"" + data + "\" Has be parsed");
            }
            myReader.close();
        } catch (FileNotFoundException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }

        System.out.println("\u001B[46m" + "\u001B[30m" + "====================" + " Parsing Completed " + "====================" + "\u001B[0m");

        System.out.println("\u001B[45m" + "\u001B[30m" + "====================" + " Sorting Instructions by Time " + "====================" + "\u001B[0m");
        // Sort Instructions by time
        Instructions.sort(Comparator.comparing(o -> o.time));
        System.out.println("\u001B[45m" + "\u001B[30m" + "====================" + " Sorting Completed " + "====================" + "\u001B[0m");
        // Execute Instructions
        for (Instruction inst: Instructions) {
            LocalDateTime now = LocalDateTime.now();

            long sleepDuration = Duration.between(now, inst.time).toMillis();
            TimeUnit.MILLISECONDS.sleep(sleepDuration);
            Thread instruction = new Thread(inst);
//          instruction.sleep(sleepDuration);
            instruction.start();
        }
    }

}
