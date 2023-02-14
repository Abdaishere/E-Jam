package Instructions;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Disconnect extends Instruction{
    String Target;

    public Disconnect(LocalDateTime time, String target) {
        super(time);
        Target = target;
    }

    @Override
    public void run() {
        System.out.println("\u001B[31m" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy:MM:dd:HH:mm:ss.SSSSSS")) + " Disconnecting : " + Target + "\u001B[0m");
    }

    @Override
    public String toString() {
        return super.toString() +  " Disconnecting : " + Target;
    }
}
