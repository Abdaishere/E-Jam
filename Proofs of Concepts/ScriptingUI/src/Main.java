import Instructions.Instruction;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Scanner;

public class Main {
    //TODO make the input config from args[0] array and the output log to args[1]
    public static void main(String[] args) {
        ArrayList<Instruction> Instructions = new ArrayList<>();
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

                System.out.println(data);
            }
            myReader.close();
        } catch (FileNotFoundException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
    }
}
