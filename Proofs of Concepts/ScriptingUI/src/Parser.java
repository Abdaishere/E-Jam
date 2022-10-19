import Instructions.Connect;
import Instructions.Disconnect;
import Instructions.Generate;
import Instructions.Instruction;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;

public class Parser {
    // starting from the time the app started
    static LocalDateTime now = LocalDateTime.now();
    /**
        Used for parsing an instruction from a file or CLI to a specific object used for this instruction to run at a specific time
     @param d the instruction line to be parsed
     @return result of the parsing into an object that can be modified at any time and be easily viewed via the Debugger or the GUI
     */
    public static ArrayList<Instruction> Parse(String d) {

        LocalDateTime tempTime;
        String[] input = d.split(" ", 4);

        // first part, time of occurrence {'!' after in (HH:mm:ss.SSSSSS format) , '@' in (yyyy:MM:dd:HH:mm:ss.SSSSSS format)}
        if (input[0].equals("!")) {
            tempTime = TimeAdder(now, input[1]);
        } else if (input[0].equals("@")) {
            tempTime = LocalDateTime.parse(input[1], DateTimeFormatter.ofPattern("yyyy:MM:dd:HH:mm:ss.SSSSSS"));
        } else throw new Error("undefined input at Time of instruction :" + d);
        now = tempTime;
        // Second part, Function to use {(+,-) Connection and Disconnection {( & ) More than one Connections or Disconnections} , (=) Sending}
        // Notice :If a function can have the symbol '&' in it the '&' must be space separated from any input involved in the instruction otherwise it will be part of the instruction's input
        switch (input[2]) {
            // Connection and Disconnection {(+,-) Connection and Disconnection {( & ) More than one Connections or Disconnections}}
            case "+" -> {
                String[] Targets = input[3].split(" & ");

                ArrayList<Instruction> result = new ArrayList<>();

                for (String t : Targets) {
                    result.add(new Connect(tempTime, t));
                }
                return result;

            }
            case "-" -> {
                String[] Targets = input[3].split(" & ");

                ArrayList<Instruction> result = new ArrayList<>();

                for (String t : Targets) {
                    result.add(new Disconnect(tempTime, t));
                }
                return result;

            }
            // Sending Function { From, To {Packet-info, Target, {( & ) many connections}}
            case "=" -> {

                String[] Parameters = input[3].split(" ", 2);
                String[] Targets = Parameters[1].split(" & ");

                ArrayList<Instruction> result = new ArrayList<>();

                for (String t : Targets) {
                    String[] Data = t.split(" ", 2);
                    result.add(new Generate(tempTime, Parameters[0], Data[0], Data[1]));
                }
                return result;

            }
            default -> throw new Error("undefined input at Function of instruction :" + d);
        }
    }

    /**
     *  find the absolute time for a specific date starting from the last time entered
     * @param now the last time entered
     * @param i relative time
     * @return absolute time
     */
    public static LocalDateTime TimeAdder(LocalDateTime now, String i) {
        final DateTimeFormatter timeColonFormatter = new DateTimeFormatterBuilder().appendPattern("HH:mm:ss.SSSSSS").parseDefaulting(ChronoField.YEAR_OF_ERA, 1)
                .parseDefaulting(ChronoField.MONTH_OF_YEAR, 1)
                .parseDefaulting(ChronoField.DAY_OF_MONTH, 1)
                .toFormatter(); ;

        LocalDateTime parsed = LocalDateTime.parse(i, timeColonFormatter);
        now = now.plusNanos(parsed.getNano());
        now = now.plusSeconds(parsed.getSecond());
        now = now.plusMinutes(parsed.getMinute());
        now = now.plusHours(parsed.getHour());

        return now;
    }
}
