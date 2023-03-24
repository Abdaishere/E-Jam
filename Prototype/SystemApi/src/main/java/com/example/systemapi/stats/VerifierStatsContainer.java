package com.example.systemapi.stats;

/**
 * Special implementation of the statsContainer tailored for Verifiers
 * @author Khaled Waleed
 */

public class VerifierStatsContainer extends StatsContainer
{
    public String sourceMac;
    public String streamId;
    public long receivedCorrectPckts;
    public long receivedWrongPckts;
    public long droppedPckts;
    public long receivedOutOfOrderPckts;

    VerifierStatsContainer(String s)
    {
        super(s);
    }

    /**
     * Rebuild the data object using new raw data source
     * @param string the string containing raw data
     */
    @Override
    void rebuild_from_string(String string)
    {
        String[] values = string.split(String.valueOf(rawDataDelimiter));

        sourceMac = values[0];
        streamId = values[1];
        receivedCorrectPckts = Long.parseLong(values[2]);
        receivedWrongPckts = Long.parseLong(values[3]);
        droppedPckts = Long.parseLong(values[4]);
        receivedOutOfOrderPckts = Long.parseLong(values[5]);
    }
}
