public with sharing class QStaticTracker
{
  public static boolean m_b360InsertTriggerFired  {get; set;}
  public static boolean m_b360DeleteTriggerFired  {get; set;}
  public static boolean m_b360UpdateTriggerFired  {get; set;}
  
  public static boolean m_bTaskUpsertTriggerFired  {get; set;}
  
  public static boolean m_bEventInsertTriggerFired  {get; set;}
  public static boolean m_bEventUpdateTriggerFired  {get; set;}
  
  public static boolean m_bCallInsertTriggerFired  {get; set;}
  public static boolean m_bCallUpdateTriggerFired  {get; set;}
  
  public static boolean m_bCallAfterInsertUpdateDeleteTriggerFired  {get; set;}
}