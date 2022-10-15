package Instructions;

import java.time.LocalDateTime;

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
        System.out.println(time.toString() + " " + From + " Sending " + PaketInfo + " " + To);
    }

    @Override
    public String toString() {
        return time.toString() + " " + From + " Sending " + PaketInfo + " " + To;
    }
}
