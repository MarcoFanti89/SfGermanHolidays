@isTest
public without sharing class GermanHolidays_Test {

    @isTest
    public static void testHolidays(){

        //will check holidays for Berlin
        GermanHolidays holiday = new GermanHolidays('BE');

        System.assertEquals(false, holiday.IsWorkingDay(Date.newInstance(2020, 01, 01))); //new year
        System.assertEquals(true, holiday.IsWorkingDay(Date.newInstance(2021, 01, 06))); //epiphany
        System.assertEquals(false, holiday.IsWorkingDay(Date.newInstance(2021, 03, 08))); //womens day
        System.assertEquals(false, holiday.IsWorkingDay(Date.newInstance(2019, 12, 26))); //2nd christmas
        System.assertEquals(false, holiday.IsWorkingDay(Date.newInstance(2021, 01, 24))); //normal sunday
        
        // the following testst are only to get to 100%, if not is already > 80%

        System.assertEquals(true, holiday.IsWorkingDay(Date.newInstance(2021, 1 , 27))); //working day
        System.assertEquals(true, holiday.IsWorkingDay(Date.newInstance(2021, 01, 06))); //epiphany working day in berlin
        System.assertEquals(true, holiday.IsWorkingDay(Date.newInstance(2021, 06, 03))); //corpus working day in berlin
        System.assertEquals(true, holiday.IsWorkingDay(Date.newInstance(2019, 08, 15))); //assumption working day in berlin
        System.assertEquals(true, holiday.IsWorkingDay(Date.newInstance(2022, 10, 31))); //reformation is working day in berlin
        System.assertEquals(true, holiday.IsWorkingDay(Date.newInstance(2022, 11, 01))); //all saints is working day in berlin
        System.assertEquals(true, holiday.IsWorkingDay(Date.newInstance(2021, 11, 17))); //repetance is working day in berlin

    }

    
    /** pass an invalid state, see it fail */
    @isTest
    public static void testException(){
        try{
            GermanHolidays holiday = new GermanHolidays('Fantiland');
            System.assert(false, 'Class is accepting invalid state');
        } catch(GermanHolidays.GermanHolidays_Exception ex){
            
        }
    }
}