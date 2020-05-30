import 'dart:ffi';

import 'package:cia_flutter/common_widget/custom_dialog.dart';
import 'package:cia_flutter/common_widget/radio_list.dart';
import 'package:cia_flutter/models/deductible_item.dart';
import 'package:cia_flutter/models/sumInsuredItem.dart';
import 'package:cia_flutter/utils/assetutils.dart';
import 'package:cia_flutter/utils/colors.dart';
import 'package:cia_flutter/utils/constants.dart';
import 'package:cia_flutter/utils/utils.dart';
import 'package:flutter/material.dart';

class PlanCustomizeScreen extends StatefulWidget {
  @override
  _PlanCustomizeScreenState createState() => _PlanCustomizeScreenState();
}

class SelectionTypeItem {
  SelectionTypeItem({this.title = '', this.isSelected = false, this.count = 0});

  String title;
  bool isSelected;
  int count;

  bool operator ==(o) =>
      o is SelectionTypeItem &&
      o.title == title &&
      o.isSelected == isSelected &&
      o.count == count;

  //Overriden the get hashCode method
  int get hashCode => title.hashCode ^ isSelected.hashCode ^ count.hashCode;
}

class FilterItemObject {
  FilterItemObject({
    this.title = '',
    this.code = '',
    this.isSelected = false,
  });

  String title;
  String code;
  bool isSelected;

  bool operator ==(o) =>
      o is FilterItemObject &&
      o.title == title &&
      o.code == code &&
      o.isSelected == isSelected;

  //Overriden the get hashCode method
  int get hashCode => title.hashCode ^ code.hashCode ^ isSelected.hashCode;
}

class _PlanCustomizeScreenState extends State<PlanCustomizeScreen> {
  List<FilterItemObject> insCompanies = new List();
  List<FilterItemObject> insPlanList = new List();
  List<SelectionTypeItem> selecttionTypeList = new List();
  double minRange;
  double maxRange;
  double sliderValue;
  int division;
  int selectedInsCompanyListIndex = 0;
  int selectedInsPlanListIndex = 0;
  int selectedSumInsuredListIndex = 0;
  int selectedDeductibleListIndex = 0;
  int selectedPlanType = 0;
  int selectionTypeIndex = 0;

  @override
  void initState() {
    super.initState();
    setDefaultListSets();
  }

  setDefaultListSets() {
    selecttionTypeList
        .add(new SelectionTypeItem(title: "Company", isSelected: true));
    selecttionTypeList
        .add(new SelectionTypeItem(title: "Plan", isSelected: false));
    selecttionTypeList
        .add(new SelectionTypeItem(title: "Premium", isSelected: false));
    selecttionTypeList.add(new SelectionTypeItem(
        title: "Sum Insured", isSelected: false, count: 1));
    selecttionTypeList.add(new SelectionTypeItem(
        title: "Deductible", isSelected: false, count: 1));

    insCompanies.add(new FilterItemObject(
        title: "Aditya Birla", code: "01", isSelected: false));
    insCompanies.add(new FilterItemObject(
        title: "Bajaj Allianz General", code: "02", isSelected: false));
    insCompanies.add(new FilterItemObject(
        title: "HDFC Ergo Health", code: "03", isSelected: false));
    insCompanies.add(new FilterItemObject(
        title: "ICICI Lombard", code: "04", isSelected: false));
    insCompanies.add(new FilterItemObject(
        title: "ManipalCigna", code: "05", isSelected: false));
    insCompanies.add(new FilterItemObject(
        title: "Religare Health", code: "06", isSelected: false));

    insPlanList.add(new FilterItemObject(
        title: "Diamond plan", code: "11", isSelected: false));
    insPlanList.add(new FilterItemObject(
        title: "Family Health Optma", code: "12", isSelected: false));
    insPlanList.add(new FilterItemObject(
        title: "Comprehensive plan", code: "13", isSelected: false));
    insPlanList.add(new FilterItemObject(
        title: "Red carpet plan", code: "14", isSelected: false));
    insPlanList.add(new FilterItemObject(
        title: "ProHealth Protect", code: "15", isSelected: false));
    insPlanList.add(new FilterItemObject(
        title: "ProHealth plus", code: "16", isSelected: false));

    minRange = 400000;
    maxRange = 1500000;
    sliderValue = 400000;

    division = maxRange.round() - minRange.round();
  }

  resetSelectionTypeList() {
    for (var item in selecttionTypeList) {
      var index = selecttionTypeList.indexOf(item);
      if (index == 0) {
        item.isSelected = true;
        item.count = 0;
      } else if (index == 3 || index == 4) {
        item.isSelected = false;
      } else {
        item.isSelected = false;
        item.count = 0;
      }
    }
  }

  resetCompayList() {
    for (var item in insCompanies) {
      item.isSelected = false;
    }
  }

  resetPlanList() {
    for (var item in insPlanList) {
      item.isSelected = false;
    }
  }

  resetSumInsuredList() {
    for (var item in sumInsuredList) {
      var index = sumInsuredList.indexOf(item);
      if (index == 0) {
        item.isDefault = true;
      } else {
        item.isDefault = false;
      }
    }
  }

  resetDeductibleList() {
    for (var item in deductibleList) {
      var index = deductibleList.indexOf(item);
      if (index == 0) {
        item.isSelected = true;
      } else {
        item.isSelected = false;
      }
    }
  }

  resetFilter() {
    setState(() {
      resetSelectionTypeList();
      resetCompayList();
      resetPlanList();
      resetSumInsuredList();
      resetDeductibleList();
      selectedInsCompanyListIndex = 0;
      selectedInsPlanListIndex = 0;
      selectedSumInsuredListIndex = 0;
      selectedDeductibleListIndex = 0;
      sliderValue = 400000;
      selectionTypeIndex = 0;
    });
  }

  onSelectionTypeItemClick(SelectionTypeItem selectedItem, int index) {
    for (var item in selecttionTypeList) {
      if (selectedItem == item) {
        item.isSelected = true;
      } else {
        item.isSelected = false;
      }
    }
    setState(() {
      selectionTypeIndex = index;
    });
  }

  onDeductibleItemClick(DeductibleItem selectedItem, int index) {
    for (var item in deductibleList) {
      if (selectedItem == item) {
        item.isSelected = true;
      } else {
        item.isSelected = false;
      }
    }
    selecttionTypeList[selectionTypeIndex].count = getDeductibleCount();
    selectedDeductibleListIndex = index;

    setState(() {});
  }

  onSumInsuredItemClick(SumInsuredItem selectedItem, int index) {
    for (var item in sumInsuredList) {
      if (selectedItem == item) {
        item.isDefault = true;
      } else {
        item.isDefault = false;
      }
    }
    selecttionTypeList[selectionTypeIndex].count = getSumInsuredCount();
    selectedSumInsuredListIndex = index;
    setState(() {});
  }

  int getTotalSelectedComanyCount() {
    int count = 0;
    for (var item in insCompanies) {
      if (item.isSelected) {
        count++;
      }
    }
    return count;
  }

  int getTotalSelectedPlanCount() {
    int count = 0;
    for (var item in insPlanList) {
      if (item.isSelected) {
        count++;
      }
    }
    return count;
  }

  int getSumInsuredCount() {
    int count = 0;
    for (var item in sumInsuredList) {
      if (item.isDefault) {
        count++;
        break;
      }
    }
    return count;
  }

  int getDeductibleCount() {
    int count = 0;
    for (var item in deductibleList) {
      if (item.isSelected) {
        count++;
        break;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // Opacity(
            //   opacity: 0.2,
            //   child:
            //       Image.asset(AssetUtils.health_quote_bg, fit: BoxFit.fitWidth),
            // ),
            // Positioned(
            //   bottom: 0,
            //   right: 0,
            //   child: Opacity(
            //     opacity: 0.06,
            //     child: Image.asset(
            //       AssetUtils.bottom_bg_image,
            //       width: 300,
            //       // fit: BoxFit.fitHeight
            //     ),
            //   ),
            // ),
            Container(
              height: MediaQuery.of(context).padding.top,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 2.0,
                  )
                ],
              ),
              height: kToolbarHeight + 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text(
                        'Filters',
                        style: TextStyle(
                            fontSize: 20,
                            color: ColorUtils.filterDarkGreyColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        onTap: () {
                          resetFilter();
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 8, bottom: 8),
                          child: Text('CLEAR ALL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.blueThemeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: ColorUtils.filterLightGreyColor.withOpacity(0.7),
                // color: Colors.green,
                margin: EdgeInsets.only(top: 1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      Container(
                                        color: ColorUtils.filterDarkGreyColor
                                            .withOpacity(0.4),
                                        height: 0.4,
                                      ),
                                  padding: EdgeInsets.only(top: 0, bottom: 0),
                                  itemCount: selecttionTypeList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    return selectionTypeItemWidget(
                                        selecttionTypeList[i], i);
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 0.0), //(x,y)
                                blurRadius: 0.1,
                              )
                            ],
                          ),
                          child: displayWidgetSelectionTypeWise()),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(1.0, 0.0), //(x,y)
              blurRadius: 1.0,
            )
          ],
        ),
        height: 50,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    // padding:
                    //     EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 8),
                    child: Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                            color: ColorUtils.filterDarkGreyColor,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
                width: 1.5,
                height: 25,
                child: VerticalDivider(color: Colors.grey)),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    // padding:
                    //     EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 8),
                    child: Center(
                      child: Text(
                        "APPLY",
                        style: TextStyle(
                            color: ColorUtils.blueThemeColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectionTypeItemWidget(SelectionTypeItem item, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onSelectionTypeItemClick(item, index);
        },
        child: Container(
          color: item.isSelected
              ? Colors.white
              : ColorUtils.filterLightGreyColor.withOpacity(0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 0.0, top: 20, bottom: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.5,
                            fontWeight: item.isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: ColorUtils.filterDarkGreyColor),
                      ),
                    ),
                    item.count != 0
                        ? Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Text(
                              "${item.count.toString()}",
                              style: TextStyle(
                                  letterSpacing: 1.5,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget companyAndPlanListItemWidget(FilterItemObject item, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            item.isSelected = !item.isSelected;
            if (selectionTypeIndex == 0) {
              selecttionTypeList[selectionTypeIndex].count =
                  getTotalSelectedComanyCount();
            } else {
              selecttionTypeList[selectionTypeIndex].count =
                  getTotalSelectedPlanCount();
            }
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: item.isSelected
                  ? Icon(
                      Icons.check,
                      color: ColorUtils.blueThemeColor,
                    )
                  : Icon(
                      Icons.check,
                      color: Color(0xFFECECED),
                    ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      item.title,
                      style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: item.isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget insPremiumSelection() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10, top: 10),
            child: Row(
              children: <Widget>[
                Text(
                  "Selected Premium : ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                ),
                getUniversal5Space(isHorizontal: true),
                Text(
                  sliderValue.toString(),
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            // margin: EdgeInsets.only(left: 5, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Slider(
                        activeColor: ColorUtils.blueThemeColor,
                        value: sliderValue,
                        min: minRange,
                        max: maxRange,
                        divisions: (division == 0) ? 1 : division,
                        // label: '${sliderValue.round()}',
                        onChanged: (double value) {
                          setState(() {
                            sliderValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        minRange.toString(),
                        style: TextStyle(
                            color: ColorUtils.filterDarkGreyColor,
                            fontSize: 12,
                            letterSpacing: 1.2),
                      ),
                      Text(
                        maxRange.toString(),
                        style: TextStyle(
                            color: ColorUtils.filterDarkGreyColor,
                            fontSize: 12,
                            letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sumInsuredListItemWidget(SumInsuredItem item, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onSumInsuredItemClick(item, index);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: item.isDefault
                  ? Icon(
                      Icons.adjust,
                      color: ColorUtils.blueThemeColor,
                      size: 20,
                    )
                  : Icon(
                      Icons.adjust,
                      color: Color(0xFFECECED),
                      size: 20,
                    ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      item.displaySI,
                      style: TextStyle(letterSpacing: 1.5, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget deductibleListItemWidget(DeductibleItem item, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onDeductibleItemClick(item, index);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: item.isSelected
                  ? Icon(
                      Icons.adjust,
                      color: ColorUtils.blueThemeColor,
                      size: 20,
                    )
                  : Icon(
                      Icons.adjust,
                      color: Color(0xFFECECED),
                      size: 20,
                    ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      item.deductibleDisplay,
                      style: TextStyle(letterSpacing: 1.5, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayWidgetSelectionTypeWise() {
    switch (selectionTypeIndex) {
      case 0:
      case 1:
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) => Container(
                        color: ColorUtils.filterDarkGreyColor.withOpacity(0.5),
                        height: 0.2,
                      ),
                  padding: EdgeInsets.only(top: 0, bottom: 0),
                  itemCount: selectionTypeIndex == 0
                      ? insCompanies.length
                      : insPlanList.length,
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return companyAndPlanListItemWidget(
                        selectionTypeIndex == 0
                            ? insCompanies[i]
                            : insPlanList[i],
                        i);
                  }),
            ),
          ],
        );
        break;
      case 2:
        return insPremiumSelection();
        break;
      case 3:
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) => Container(
                        color: ColorUtils.filterDarkGreyColor.withOpacity(0.5),
                        height: 0.5,
                      ),
                  padding: EdgeInsets.only(top: 0, bottom: 0),
                  itemCount: sumInsuredList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return sumInsuredListItemWidget(sumInsuredList[i], i);
                  }),
            ),
          ],
        );
      case 4:
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) => Container(
                        color: ColorUtils.filterDarkGreyColor.withOpacity(0.5),
                        height: 0.5,
                      ),
                  padding: EdgeInsets.only(top: 0, bottom: 0),
                  itemCount: deductibleList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return deductibleListItemWidget(deductibleList[i], i);
                  }),
            ),
          ],
        );
        break;
      default:
        return Container();
    }
  }
}
