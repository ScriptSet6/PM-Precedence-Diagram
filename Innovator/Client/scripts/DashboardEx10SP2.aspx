<%@ Page Language="VB"  validateRequest="false"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="expires" content="0">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-cache">
<!-- #INCLUDE FILE="include/InitialSetupHeader.aspx" -->
<script src="../javascript/include.aspx?classes=ScriptSet2" type="text/javascript"></script>

<script>
//var dashName = QueryString("dashboardName").toString(); // ++++ DMDiagram comment out not needed ----
var methodName = QueryString("methodName").toString(); // ++++ DMDiagram ----"

<%
Dim body As String
body =Request.QueryString("body")
%> 

// var body = QueryString("body").toString(); // ++++ DMDiagram ----
var body="<%=body%>";
var svgName = "SVGDashboard";

var svgObj = null;
var svgWindow = null;
var svgReady = false;

var aras = opener.aras;
top.aras=aras;
window.onunload = function onunload_handler()
		{
			// prevent InitialSetupHeader from logging out on closing window
		}
onload = function onload_handler()
{
 setTimeout('initSVG()', 50);
 if (document.body.clientWidth)
 {
 	var svgContent = document.getElementById("svgContent");
 	svgContent.style.width = document.body.clientWidth * .99;
 	svgContent.style.height = document.body.clientHeight * .99;
  document.embeds[svgName].style.width = document.body.clientWidth * .99 + "px";
  document.embeds[svgName].style.height = document.body.clientHeight * .99 + "px";
 }
}

function initSVG() {

	if (!svgReady) { setTimeout("initSVG()", 50); return; }
	svgObj = document.getElementById(svgName);
	svgWindow = svgObj.getSVGDocument().defaultView == undefined ? svgObj.getWindow() : svgObj.getSVGDocument().defaultView;
	var svgDocument = svgWindow.document == undefined ? svgWindow.getDocument().documentElement : svgWindow.document.documentElement;
	svgDocument.setAttribute("width", document.body.clientWidth * .99 + "px");
	svgDocument.setAttribute("height", document.body.clientHeight * .99 + "px");
  loadDashboard();
}

dashboardHelper = {
	_math: {
		sin: function (angle) {
			return Math.sin(angle).toFixed(20);
		},
		cos: function (angle) {
			return Math.cos(angle).toFixed(20);
		},
		attrSum: function (nodes, attributeName) {
			var index = 0,
				currNode = null,
				sum = 0;
			for (index; index < nodes.length; index += 1) {
				currNode = nodes[index];
				sum += Number(currNode.getAttribute(attributeName));
			}
			return sum;
		}
	}, 
	_getRandomColor: function () {
		var redPart = 255 * Math.random(),
			greenPart = 255 * Math.random(),
			bluePart = 255 * Math.random(),
			color = 'rgb(' + redPart + ',' + greenPart + ',' + bluePart + ')';
		return color;
	},
	fillAttributes: function (dashboardItem) {
		var dom = dashboardItem.dom,
			charts = dom.selectNodes("palette/chart"),
			chartsCount = charts.length,
			currChart = null,
			currSeries = null,
			index = 0;
		for	(index; index < chartsCount; index +=1) {
			currChart = charts[index];
			currSeries = currChart.selectSingleNode("./series");
			var seriesColor = currSeries.getAttribute("color");
			if (!seriesColor) {
				currSeries.setAttribute("color", this._getRandomColor());
			}
			var datums = currSeries.selectNodes("./datum"),
				datumsYAttrSum = this._math.attrSum(datums, "y-value"),
				datumsCount = datums.length,
				index1 = 0,
				datum = null;
			for	(index1; index1 < datumsCount; index1 +=1) {
				datum = datums[index1];
				var datumColor = datum.getAttribute("color");
				if (!datumColor) {
					datum.setAttribute("color", this._getRandomColor());
				}
				if ("pie" === currChart.getAttribute("type")) {
					var position = datum.selectNodes("./preceding-sibling::*").length + 1;
					var prevNodes = datum.selectNodes("../datum[position() <" + position + "]"),
						prevNodesWithCurr =  datum.selectNodes("../datum[position() <=" + position + "]"),
						prevDatumsYAttrSum = this._math.attrSum(prevNodes, "y-value"),
						prevDatumWithCurrYAttrSum = this._math.attrSum(prevNodesWithCurr, "y-value"),
						startAngle = prevDatumsYAttrSum * (360 / datumsYAttrSum),
						endAngle = prevDatumWithCurrYAttrSum * (360 / datumsYAttrSum),
						textAngle = (prevDatumsYAttrSum + Number(datum.getAttribute("y-value")) / 2) * (360 / datumsYAttrSum),
						startSin = this._math.sin(startAngle * Math.PI / 180),
						startCos = this._math.cos(startAngle * Math.PI / 180),
						endSin = this._math.sin(endAngle * Math.PI / 180),
						endCos = this._math.cos(endAngle * Math.PI / 180),
						textSin = this._math.sin(textAngle * Math.PI / 180),
						textCos = this._math.cos(textAngle * Math.PI / 180);
						datum.setAttribute("startAngle", startAngle);
						datum.setAttribute("endAngle", endAngle);
						datum.setAttribute("startSin", startSin);
						datum.setAttribute("startCos", startCos);
						datum.setAttribute("endSin", endSin);
						datum.setAttribute("endCos", endCos);
						datum.setAttribute("textSin", textSin);
						datum.setAttribute("textCos", textCos);
				}
			}
		}
	}
}
function htmlDecode(input){
  var e = document.createElement('div');
  e.innerHTML = input;
  return e.childNodes[0].nodeValue;
}
function loadDashboard()
{ 
  var innovator = top.aras.newIOMInnovator();
  if (innovator === undefined)
  {
    alert(top.aras.getResource("",'dashboard.error_creating_an_innovator_object'));
    return;
  }
    // ++++ DMDiagram ++++
		
    var qry1 = innovator.newItem();
		
    var s = "";// a string containing svg to be displayed
    var res = innovator.applyMethod(methodName,body);
    if (res.isError()) {top.aras.AlertError("Error getting svg, " + res.getErrorString()); return;}
    s=res.getResult();
    if (s=="") {top.aras.AlertError("Failed to get SVG from server."); return;}
  //var chartItem = innovator.applyMethod('Build Dashboard', '<DashboardName>' + dashName + '</DashboardName>');
   //dashboardHelper.fillAttributes(chartItem);
   //if (chartItem.isError() || chartItem.dom === undefined || chartItem.dom.selectSingleNode('//palette') === undefined) {
   //alert(top.aras.getResource("",'dashboard.failed_to_load',chartItem.getErrorDetail()));
   //return;
   //}
   // ---- DMDiagram ----
 
  var svgDom = innovator.newXMLDocument();
  // var s = chartItem.applyStylesheet(top.aras.getScriptsURL()+"../styles/svg_charts.xsl","URL"); // ++++ DMDiagram comment out not needed ----
  svgDom.loadXML(s);


  if (svgDom === undefined || svgDom.selectSingleNode('//svg') === undefined) {
   alert(top.aras.getResource("", 'dashboard.failed_to_load_error_generating_graphics'));
   return;
  }
  if (svgObj.getSVGDocument().defaultView == undefined)
  {
  	svgWindow.clearContents();
  	svgWindow.addContent(svgDom.xml);
  } else
  {
  	var svgContent = document.getElementById("svgContent");
  	svgContent.style.display = "";
  	document.getElementById(svgName).style.display = "none";

  	var root = document.createElementNS(svgContent, "svg");
  	root.setAttribute("width", "100%");
  	root.setAttribute("height", "100%");
  	svgContent.appendChild(root);
  	addNode(svgDom.documentElement, svgContent.firstChild, document);
  }
}

function cleanWhiteSpace(element)
{
	var cur = element.firstChild;

	while (cur != null)
	{
		if (cur.nodeType == 3 && !/\S/.test(cur.nodeValue))
		{
			element.removeChild(cur);
		}
		else if (cur.nodeType == 1)
		{
			cleanWhiteSpace(cur);
		}
		cur = cur.nextSibling;
	}
}

function addNode(node, root, doc)
{
	cleanWhiteSpace(node);
	var svg_ = 'http://www.w3.org/2000/svg';
	if (node.tagName == undefined && node.nodeType == 3)
	{
		root.textContent = node.xml ? node.xml : node.text;
		return;
	}
	var svgEl = doc.createElementNS(svg_, node.tagName);
	if (node.attributes != null){
		var isFfxValueLabel = top.aras.Browser.isFf() && node.attributes["class"] && node.attributes["class"].nodeValue == "xValueLabel";
		for (var i = 0; i < node.attributes.length; i++){
			var nodeValue = isFfxValueLabel && node.attributes[i].name == "transform" ? node.attributes[i].value + "rotate(90)"
																					: node.attributes[i].value;

			svgEl.setAttribute(node.attributes[i].name, nodeValue);
		}
	}
	root.appendChild(svgEl);
	if (node.childNodes.length > 0)
	for (var i = 0; i < node.childNodes.length; i++)
	{
		addNode(node.childNodes[i], svgEl, doc);
	}
}
</script>
</head>
<body bgcolor="#FFFFFF" >
<span id="svg_span" style="position:absolute; top:0px; left:0px; width:0; height:0;display:block;">
  <div id="svgContent" name="svgContent" style=" display:block;"></div>
 <embed width="800" height="600" src="../xml/starter.svg" name="SVGDashboard" id="SVGDashboard" />
</span>
<script>

//  if (!top.aras) top.aras = opener.aras;  // ++++ DMDiagram ----
  //alert("Hello");
  var xmlResource = aras.getI18NXMLResource("starter.svg");
  var obj = document.getElementById("svg_span");
	obj.style.display = "block";
	obj.getElementsByTagName("embed")[0].src = xmlResource;
	//alert("J-" + obj.getElementsByTagName("embed")[0].src);
</script>
</body>
</html>
