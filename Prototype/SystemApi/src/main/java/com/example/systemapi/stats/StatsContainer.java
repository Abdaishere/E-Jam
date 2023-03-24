package com.example.systemapi.stats;

/**
 * @author Khaled Waleed
 * This is an interface for a statisics container, a statisics container is a data object holding statistics
 * produced from a generator or a verifier
 */
public abstract class StatsContainer
{
    protected char rawDataDelimiter = ' ';

    StatsContainer() {}
    StatsContainer(String s)
    {
        rebuild_from_string(s);
    }
    /**
     * Rebuild the data object using new raw data source
     * @param string the string containing raw data
     */
    abstract void rebuild_from_string(String string);

    /**
     * Change the character used to separate values in a raw data stream
     * the Character is space by default
     * @param character the new character to be used
     */
    public void setRawDataDelimiter(char character)
    {
        rawDataDelimiter = character;
    }
}
