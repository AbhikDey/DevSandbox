public with sharing class QUtils {
	////////Add Debug info
	public static void Debug(string strMessage)
	{
		System.Debug('\n\n\n*******************************************************\n' + strMessage + '\n*******************************************************\n\n\n');
	}
	////////Add Error
	public static void AddError(string strMessage)
	{
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,strMessage));
	}
	////////Add Info
	public static void AddInfo(string strMessage)
	{
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,strMessage));
	}
	////////Add Warning
	public static void AddWarning(string strMessage)
	{
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING,strMessage));
	}
	
	public static testmethod void myUnitTest()
	{
		QUtils.Debug('Salut le monde.');
		QUtils.AddError('Salut le monde.');
		QUtils.AddInfo('Salut le monde.');
		QUtils.AddWarning('Salut le monde.');
	}
}