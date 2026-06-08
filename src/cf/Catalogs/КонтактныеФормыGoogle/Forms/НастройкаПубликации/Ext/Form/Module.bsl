
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	АдресЭП = Параметры.АдресЭП;
	КодСкрипта = "function doGet(e) {
	|  
	|}
	|
	|function emailFormSubmission(e)
	|{
	|  var form = e.source;
	|  var theEmail = """+АдресЭП+""";
	|  var theSubject = ""Заполнена форма "" + form.getTitle();
	|  var theBody = ""formId: "" + form.getId() + ""; <br/> <br/>"";
	|  var formResponses = form.getResponses();
	|  var formResponse = formResponses[formResponses.length - 1];
	|  var itemResponses = formResponse.getItemResponses();
	|  for (var j = 0; j < itemResponses.length; j++) {
	|    
	|    var itemResponse = itemResponses[j];
	|    theBody = theBody + itemResponse.getItem().getTitle() +"": "";
	|    theBody = theBody + itemResponse.getResponse() + ""; <br/>"";
	|    
	|  }
	|   
	|      
	|  MailApp.sendEmail(theEmail, theSubject, """",{htmlBody: theBody});
	|}
	|
	|function doPost(e) {
	|  
	|  var method = e.parameter.method;
	|  
	|  if (method == ""delete"") 
	|  {
	|    deleteForm(e);
	|    var HTMLString = ""Form succesfully deleted;"";
	|  
	|    HTMLOutput = HtmlService.createHtmlOutput(HTMLString);
	|    return HTMLOutput;
	|    
	|  }
	| 
	|  if (method == ""create"")
	|  {
	|    var form = FormApp.create(e.parameter.formName);
	|  }
	|  else
	|  { 
	|    var form = FormApp.openById(e.parameter.formId);
	|    var items = form.getItems();
	|    while(items.length > 0)
	|    {
	|     form.deleteItem(items.pop());
	|    }
	|  }
	|  
	|  var itemsValue = e.parameter.itemsValue;
	|  var choicesValue = e.parameter.choicesValue;
	|  
	|  if (itemsValue > 0)
	|  {
	|    var parametrItems = JSON.parse(e.parameter.formItems);
	|  }
	|  
	|  if (choicesValue > 0)
	|  {
	|  var parametrChoices = JSON.parse(e.parameter.formChoices);
	|  }
	|  
	|  form.setTitle(e.parameter.formTitle);
	|  form.setDescription(e.parameter.formDescription);
	|  
	|  if (e.parameter.formClosedMsg!="""")
	|  {
	|    form.setConfirmationMessage(e.parameter.formClosedMsg);
	|  }
	|   
	|  for(i = 0;i < itemsValue;i++)
	|  {
	|    var newItem = addNewItem(parametrItems[i].type,form);
	|    newItem.setTitle(parametrItems[i].title);
	|   
	|    if (parametrItems[i].isRequired == ""true"")
	|    {
	|      newItem.setRequired(true);
	|    }
	|    
	|    if (parametrItems[i].type == ""list""||parametrItems[i].type == ""multipleChoice""||parametrItems[i].type == ""checkbox"")
	|    { 
	|      var choices = [];
	|      for (j = 0;j < choicesValue;j++) 
	|      {
	|        if (parametrChoices[j].id == parametrItems[i].id) {
	|        choices.push(newItem.createChoice(parametrChoices[j].title));
	|        }
	|      }
	|      newItem.setChoices(choices);
	|    }
	|  }
	|  
	|  if (method == ""create"")
	|  {
	|  ScriptApp.newTrigger(""emailFormSubmission"")
	|  .forForm(form)
	|  .onFormSubmit()
	|  .create();
	|  }
	|  
	|  var HTMLString = ""URL:"" + form.shortenFormUrl(form.getPublishedUrl()) + ""EndUrl"" + ""FormId:""+form.getId() + ""EndFormId""+""FormAnswers:"" + form.getSummaryUrl() +""EndFormAnswers"";
	|  
	|  HTMLOutput = HtmlService.createHtmlOutput(HTMLString);
	|  return HTMLOutput;
	|    
	|}
	|
	|function deleteForm(e)
	|{
	|  var triggers = ScriptApp.getProjectTriggers();
	|  for (i = 0;i < triggers.length;i++)
	|  { 
	|    if (triggers[i].getTriggerSourceId() == e.parameter.formId)
	|  {
	|    ScriptApp.deleteTrigger(triggers[i]);
	|  }
	|  }
	|  DriveApp.getFileById(e.parameter.formId).setTrashed(true);
	|}
	|
	|function addNewItem(type, form){
	|
	|    if (type == ""text""){
	|      newItem = form.addTextItem();
	|    }
	|    else if (type == ""date"")
	|    {
	|      newItem = form.addDateItem();
	|    }
	|    else if (type == ""time"")
	|    {
	|      newItem = form.addTimeItem();
	|    }
	|    else if (type == ""list"")
	|    {
	|      newItem = form.addListItem();
	|    }
	|    else if (type == ""checkbox"")
	|    {
	|      newItem = form.addCheckboxItem();
	|    }
	|    else if (type == ""multipleChoice"")
	|    {
	|      newItem = form.addMultipleChoiceItem();
	|    }
	|    else if (type == ""paragraphText"")
	|    {
	|      newItem = form.addParagraphTextItem();
	|    }
	|    else
	|    {
	|      newItem = form.addTextItem();
	|    }
	|  
	|  return newItem;
	|  
	|}";
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Скопировать(Команда)
	ОбщегоНазначенияБЭДКлиент.СкопироватьВБуферОбмена(КодСкрипта, НСтр("ru = 'Код для вставки скопирован'")); 
КонецПроцедуры

&НаКлиенте
Процедура СохранитьНастройкуИнтеграции(Команда)
	Закрыть(СсылкаАвторизации);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	#Если ВебКлиент Тогда
		Элементы["Скопировать"].Видимость = Ложь;
	#КонецЕсли
КонецПроцедуры

#КонецОбласти