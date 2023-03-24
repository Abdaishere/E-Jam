package com.example.systemapi.stats;

/**
 * Special implementation of the statsContainer tailored for generators
 * @author Khaled Waleed
 */
public class GeneratorStatsContainer extends StatsContainer
{
    public String targetMac;
    public String streamId;
    public long sentPckts;
    public long sentErrorPckts;


    GeneratorStatsContainer(String s)
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

        targetMac = values[0];
        streamId = values[1];
        sentPckts = Long.parseLong(values[2]);
        sentErrorPckts = Long.parseLong(values[3]);
    }
}
