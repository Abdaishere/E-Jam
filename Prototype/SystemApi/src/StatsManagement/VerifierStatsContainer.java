package StatsManagement;

/**
 * Special implementation of the statsContainer tailored for Verifiers
 * @author Khaled Waleed
 */

public class VerifierStatsContainer extends StatsContainer
{
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
        //TODO parse and fill class's parameters from the string
    }
}
