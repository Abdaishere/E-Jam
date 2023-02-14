package Instructions;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Generate extends Instruction{
    String From;
    String To;
    String PaketInfo;

    public Generate(LocalDateTime time, String from, String to, String paketInfo) {
        super(time);
        From = from;
        To = to;
        PaketInfo = paketInfo;
    }

    @Override
    public void run() {
        System.out.println("\u001B[33m" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy:MM:dd:HH:mm:ss.SSSSSS")) + " " + From + " Sending " + PaketInfo + " " + To + "\u001B[0m");
    }

    @Override
    public String toString() {
        return  super.toString() + " " + From + " Sending " + PaketInfo + " " + To;
    }
}
