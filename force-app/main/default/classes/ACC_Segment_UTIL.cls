public with sharing class ACC_Segment_UTIL {
    /****
     * @description map of a collection of GiftItems keyed by account id
     */
    public static Boolean manualOverride {
        get {
            if(manualOverride == null)
                manualOverride = true;
            return manualOverride;
        }
        set;
    }
}
