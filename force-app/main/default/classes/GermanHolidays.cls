/**
 * Utility class to determine if a specific day is a working day in Germany
 * See how itś used in the test class
 * Inspired by https://github.com/martinjw/Holiday
 */
public without sharing class GermanHolidays {

    //state in ISO 3166-2:DE format
    private String state;
    
    //"SATURDAY", "SUNDAY"
    private Set<String> nonWorkingDays;

    private static final Set<String> validStates = new Set<String>{
        'ALL', 'BW', 'BY', 'BE', 'BB', 'HB', 'HH', 'HE', 'MV', 'NI', 'NW', 'RP', 'SL', 'SN', 'ST', 'SH', 'TH'
    };

    /**
     * Pass as parameter the german state in ISO 3166-2:DE
     * eg Berlin is 'BE'
     * If ALL : it counts only the holidays valid nation-wide
     */
    public GermanHolidays(String state){
        if(state == null || !validStates.contains(state.toUpperCase())){
            throw new GermanHolidays_Exception('Invalid German state ' + state + 
                ' User configuration needs valid german state in ISO 3166-2:DE format');
        }

        this.state = state.toUpperCase();
        nonWorkingDays = getNonWorkingDays();
    }
    
    /**
     * get from the metadata the set with the non-working days for our company, eg: 'SATURDAY', 'SUNDAY'
     */
    public static Set<String> GetNonWorkingDays(){
        try{
            String nonWorkingDaysStr = [SELECT Non_Working_Days__c FROM Holiday_Setting__mdt WHERE DeveloperName = 'Germany'].Non_Working_Days__c;
    
            Set<String> nonWorkingDays = new Set<String>();
            if(String.isNotBlank(nonWorkingDaysStr)){
                for(String day : nonWorkingDaysStr.split(',')){
                    nonWorkingDays.add(day.trim().toUpperCase());
                }
            }
            return nonWorkingDays;
        } catch(QueryException ex){
            throw new GermanHolidays_Exception('The Holiday_Setting__mdt is missing for Germany');
        }
    }

    /**
     * @param day : any date
     * @return true if is a working day
     *         false if is holiday
     */
    public Boolean IsWorkingDay(Date day){
        if(nonWorkingDays.contains(GetDayOfWeek(day))) return false;

        Integer year = day.year();
        if((day == NewYear(year)) ||
            (day == Epiphany(year) && HasEpiphany()) ||
            (day == Women(year) && HasWomen()) ||
            (day == GoodFriday(year)) ||
            (day == Easter(year)) ||
            (day == EasterMonday(year)) ||
            (day == LabourDay(year)) ||
            (day == Ascension(year)) ||
            (day == PentecostMonday(year)) ||
            (day == Corpus(year) && HasCorpus()) ||
            (day == Assumption(year) && HasAssumption()) ||
            (day == GermanUnity(year)) ||
            (day == Reformation(year) && HasReformation()) ||
            (day == AllSaints(year) && HasAllSaints()) ||
            (day == Repetance(year) && HasRepetance()) ||
            (day == Christmas(year)) ||
            (day == SecondChristmas(year))){

            return false;
        }
        return true;
    }

    private Date NewYear(Integer year){
        return Date.newInstance(year, 1, 1);
    }

    private Date Epiphany(Integer year){
        return Date.newInstance(year, 1, 6);
    }

    private Boolean HasEpiphany(){
        Set<String> validStates = new Set<String>{'BW', 'BY', 'ST'};
        return validStates.contains(state);
    }

    private Date Women(Integer year){
        return Date.newInstance(year, 3, 8);
    }

    private Boolean HasWomen(){ // -> funny name
        return state == 'BE';
    }

    private Date GoodFriday(Integer year){
        return Easter(year).addDays(-2);
    }

    private Date Easter(Integer year){
        //Oudin's Algorithm
        Integer g = math.mod(year, 19);
        Integer c = year / 100;
        Integer h = math.mod(c - c / 4 - (8 * c + 13) / 25 + 19 * g + 15, 30);
        Integer i = h - (h / 28) * (1 - (h / 28) * (29 / (h + 1)) * ((21 - g) / 11));
        Integer j = math.mod(year + year / 4 + i + 2 - c + c / 4, 7);
        Integer p = i - j;
        Integer easterDay = 1 + math.mod(p + 27 + (p + 6) / 40, 31);
        Integer easterMonth = 3 + (p + 26) / 30;

        return Date.newInstance(year, easterMonth, easterDay);
    }

    private Date EasterMonday(Integer year){
        return Easter(year).addDays(1);
    }

    private Date LabourDay(Integer year){
        return Date.newInstance(year, 5, 1);
    }

    private Date Ascension(Integer year){
        return Easter(year).addDays(39);
    }

    private Date PentecostMonday(Integer year){
        return Easter(year).addDays(50);
    }

    private Date Corpus(Integer year){
        return Easter(year).AddDays((7 * 8) + 4);
    }

    private Boolean HasCorpus(){
        Set<String> validStates = new Set<String>{'BW', 'BY', 'HE', 'NW', 'RP', 'SL', 'SN', 'TH'};
        return validStates.contains(state);
    }

    private Date Assumption(Integer year){
        return Date.newInstance(year, 8, 15);
    }

    private Boolean HasAssumption(){
        Set<String> validStates = new Set<String>{'BY', 'SL'};
        return validStates.contains(state);
    }

    private Date GermanUnity(Integer year){
        return Date.newInstance(year, 10, 3);
    }

    private Date Reformation(Integer year){
        return Date.newInstance(year, 10, 31);
    }

    private Boolean HasReformation(){
        Set<String> validStates = new Set<String>{'BB', 'HH', 'MV', 'NI', 'SH', 'SN', 'ST', 'TH'};
        return validStates.contains(state);
    }

    private Date AllSaints(Integer year){
        return Date.newInstance(year, 11, 1);
    }

    private Boolean HasAllSaints(){
        Set<String> validStates = new Set<String>{'BW', 'BY', 'NW', 'RP', 'SL'};
        return validStates.contains(state);
    }

    /**
     * Repetance is the fist wednesday before beginning of advent.
     * Advent is first sunday 28 days before christmas
     */
    private Date Repetance(Integer year){
        Date advent = getPreviousDate(Christmas(year).addDays(-29), 'Sunday');
        return getPreviousDate(advent, 'Wednesday');
    }

    private Boolean HasRepetance(){
        return state == 'SN';
    }

    private Date Christmas(Integer year){
        return Date.newInstance(year, 12, 25);
    }

    private Date SecondChristmas(Integer year){
        return Date.newInstance(year, 12, 26);
    }

    /**
     * Goes back from the date passed until it meets the specificday of the week
     * @param start : date from which start
     * @param day : day in EEEE format (Monday, Tueasday, ... ), iteration will stop on this day
     */
    private static Date getPreviousDate(Date start, String day){
        day = day.toUpperCase();
        while(getDayOfWeek(start) != day){
            start = start.addDays(-1);
        }
        return start;
    }

    /**
     * Receive date return string Monday, Tueasday, ...
     */
    private static String getDayOfWeek(Date day){
        Datetime dt = DateTime.newInstance(day, Time.newInstance(0, 0, 0, 0));
        return dt.format('EEEE').toUpperCase();
    }

    public class GermanHolidays_Exception extends Exception {}
}