package Instructions;

import java.time.LocalDateTime;

public class Disconnect extends Instruction{
    String Target;

    public Disconnect(LocalDateTime time, String target) {
        super(time);
        Target = target;
    }

    @Override
    public void run() {
        System.out.println(time.toString() + "Disconnecting : " + Target);
    }

    @Override
    public String toString() {
        return time.toString() + "Disconnecting : " + Target;
    }
}
