import 'dart:ui';

import 'package:cia_flutter/utils/assetutils.dart';
import 'package:cia_flutter/utils/colors.dart';
import 'package:cia_flutter/utils/constants.dart';
import 'package:cia_flutter/utils/utils.dart';
import 'package:flutter/material.dart';

class PlanCompareScreen extends StatefulWidget {
  @override
  _PlanCompareScreenState createState() => _PlanCompareScreenState();
}

class ItemObject {
  ItemObject(
      {this.planName = '',
      this.planType = '',
      this.childAgeFloaterMax = '',
      this.childAgeFloaterMin = '',
      this.proposerAgeAtEntryMin = '',
      this.proposerAgeAtEntryMax = '',
      this.sumInsuredAvailable = '',
      this.policyTermAvailable = '',
      this.familySizeAllowed = '',
      this.restoreRechargeReinstatement = '',
      this.hospitalAccommodation = '',
      this.preAndPostHospitalisation = '',
      this.preExistingDiseases = '',
      this.ayushBenefit = '',
      this.coPayment = '',
      this.dayCareTreatments = '',
      this.diseaseswisesublimit = '',
      this.freeHealthCheckup = '',
      this.initialWaitingPeriod = '',
      this.initialYearExclusion = '',
      this.maternityBenefit = '',
      this.networkHospitals = '',
      this.noClaimBonusDiscount = '',
      this.preMedicalTest = '',
      this.premiumAmount = '',
      this.tPAClaimsAdministrator = '',
      this.sumInsured = ''});

  String planName;
  String planType;
  String childAgeFloaterMin;
  String childAgeFloaterMax;
  String proposerAgeAtEntryMin;
  String proposerAgeAtEntryMax;
  String sumInsuredAvailable;
  String policyTermAvailable;
  String familySizeAllowed;
  String restoreRechargeReinstatement;
  String hospitalAccommodation;
  String preAndPostHospitalisation;
  String preExistingDiseases;
  String initialYearExclusion;
  String maternityBenefit;
  String dayCareTreatments;
  String diseaseswisesublimit;
  String ayushBenefit;
  String preMedicalTest;
  String coPayment;
  String freeHealthCheckup;
  String initialWaitingPeriod;
  String noClaimBonusDiscount;
  String networkHospitals;
  String tPAClaimsAdministrator;
  String sumInsured;
  String premiumAmount;
}

class _PlanCompareScreenState extends State<PlanCompareScreen> {
  List<ItemObject> planList = new List();
  List<String> titleList = new List();
  List<List<String>> valuesList = new List();
  @override
  void initState() {
    super.initState();
    setData();
  }

//  Container(
  //                                       height: 40,
  //                                       child: Image.asset(
  //                                           AssetUtils.icici_pru),
  //                                     ),
  List<Widget> _buildCells(int i) {
    return List.generate(
      valuesList.length,
      (index) => i == 0
          ? Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      right: BorderSide(
                          color: ColorUtils.darkGrey.withOpacity(0.5), width: 0.2),
                      bottom: BorderSide(
                          color: ColorUtils.darkGrey.withOpacity(0.5),
                          width: 0.2))),
              padding: EdgeInsets.only(left: 10),
              width: 145.0,
              height: 40.0,
              child: Image.asset(AssetUtils.icici_pru),
            )
          : Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      right: BorderSide(
                          color: ColorUtils.darkGrey.withOpacity(0.5), width: 0.2),
                      bottom: BorderSide(
                          color: ColorUtils.darkGrey.withOpacity(0.5), width: 0.2))),
              width: 145.0,
              height: 80.0,
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      valuesList[index][i],                      
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorUtils.darkGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildTitles() {
    return List.generate(
      titleList.length,
      (index) => index != 0
          ? Container(
            padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(                                                   
                  border: Border(
                      right: BorderSide(
                          color: ColorUtils.darkGrey.withOpacity(0.5), width: 0.2),
                      bottom: BorderSide(
                          color: ColorUtils.darkGrey.withOpacity(0.5), width: 0.2))),
              width: 120.0,
              height: 80,
              // margin: EdgeInsets.all(4.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      titleList[index],
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorUtils.darkGrey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(                   
                  border: Border(
                      right: BorderSide(
                          color: ColorUtils.darkGrey.withOpacity(0.5), width: 0.2),
                      bottom: BorderSide(
                          color: ColorUtils.darkGrey.withOpacity(0.5), width: 0.2))),
              width: 120.0,
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    titleList[index],
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.blueThemeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildRows(int count) {
    return List.generate(
      titleList.length,
      (index) => Row(
        children: _buildCells(index),
      ),
    );
  }

  List<String> _fieldValueItems = [
    AssetUtils.icici_pru,
    "ICICI Prudential Life Insurance",
    "Individual",
    "91 Days",
    "25 Years",
    "18 Years",
    "65 Years",
    "3L, 4L, 5L, 7.5L,10L, 15L, 20L, 25L & 50 Lacs",
    "1 & 2 years",
    "Max. 2 Adults + 5 Children",
    "-",
    "Upto Sum Insured",
    "60 days Pre & 90 days Post Hospitalisation",
    "After 3 continuous policy years",
    "Cataract,Hernia, Hysterectomy, Joint Replacement & Hydrocele for 2 years. Refer policy wording for detailed list.",
    "For SI upto 10L waiting period is 4 yrs else 3 years",
    "Yes (144)",
    "-",
    "Up to Rs. 25000 for SI upto 10 Lacs else Rs 50,000",
    "Above age 45",
    "Nil",
    "Upto 1% of SI per Policy & Max. Rs 5000/person, after 3 continuous claim free years",
    "30 Days",
    "10% cumulative bonus every claim free year upto 100%",
    "NA|NA",
    "Family Health Plan",
    "3L, 4L, 5L, 7.5L,10L, 15L, 20L, 25L & 50 Lacs",
    "5230.49"
  ];
  List<String> _fieldValueItems1 = [
    AssetUtils.icici_pru,
    "ICICI Prudential Life Insurance",
    "Individual",
    "91 Days",
    "25 Years",
    "18 Years",
    "65 Years",
    "3L, 4L, 5L, 7.5L,10L, 15L, 20L, 25L & 50 Lacs",
    "1 & 2 years",
    "Max. 2 Adults + 5 Children",
    "-",
    "Upto Sum Insured",
    "60 days Pre & 90 days Post Hospitalisation",
    "After 3 continuous policy years",
    "Cataract,Hernia, Hysterectomy, Joint Replacement & Hydrocele for 2 years. Refer policy wording for detailed list.",
    "For SI upto 10L waiting period is 4 yrs else 3 years",
    "Yes (144)",
    "-",
    "Up to Rs. 25000 for SI upto 10 Lacs else Rs 50,000",
    "Above age 45",
    "Nil",
    "Upto 1% of SI per Policy & Max. Rs 5000/person, after 3 continuous claim free years",
    "30 Days",
    "10% cumulative bonus every claim free year upto 100%",
    "NA|NA",
    "Family Health Plan",
    "3L, 4L, 5L, 7.5L,10L, 15L, 20L, 25L & 50 Lacs",
    "5230.49"
  ];
  List<String> _fieldValueItems2 = [
    AssetUtils.icici_pru,
    "ICICI Prudential Life Insurance",
    "Individual",
    "91 Days",
    "25 Years",
    "18 Years",
    "65 Years",
    "3L, 4L, 5L, 7.5L,10L, 15L, 20L, 25L & 50 Lacs",
    "1 & 2 years",
    "Max. 2 Adults + 5 Children",
    "-",
    "Upto Sum Insured",
    "60 days Pre & 90 days Post Hospitalisation",
    "After 3 continuous policy years",
    "Cataract,Hernia, Hysterectomy, Joint Replacement & Hydrocele for 2 years. Refer policy wording for detailed list.",
    "For SI upto 10L waiting period is 4 yrs else 3 years",
    "Yes (144)",
    "-",
    "Up to Rs. 25000 for SI upto 10 Lacs else Rs 50,000",
    "Above age 45",
    "Nil",
    "Upto 1% of SI per Policy & Max. Rs 5000/person, after 3 continuous claim free years",
    "30 Days",
    "10% cumulative bonus every claim free year upto 100%",
    "NA|NA",
    "Family Health Plan",
    "3L, 4L, 5L, 7.5L,10L, 15L, 20L, 25L & 50 Lacs",
    "5230.49"
  ];

  setData() {
    titleList = [
      "Attributes",
      "Plan Name",
      "Plan Type",
      "Child Age for Floater – Min	",
      "Child Age for Floater – Max	",
      "Proposer Age at Entry – Min	",
      "Proposer Age at Entry – Max	",
      "Sum Insured Available",
      "Policy Term Available",
      "Family Size Allowed",
      "Restore /Recharge /Reinstatement",
      "Hospital Accommodation",
      "Pre & Post Hospitalisation",
      "Pre-Existing Diseases",
      "Initial Year Exclusion",
      "Maternity Benefit",
      "Day Care Treatments",
      "Diseases-wise-sub-limit	",
      "AYUSH Benefit",
      "Pre-Medical Test",
      "Co-Payment",
      "Free Health Check up",
      "Initial Waiting Period",
      "No Claim Bonus / Discount",
      "Network Hospitals",
      "TPA / Claims Administrator",
      "Sum Insured",
      "Premium Amount",
    ];

    valuesList.add(_fieldValueItems);
    valuesList.add(_fieldValueItems1);
    valuesList.add(_fieldValueItems2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.appBarColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 5, right: 5, top: 10),
          child: Column(
            children: <Widget>[
              Container(
                height: kToolbarHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: ColorUtils.blackColor,
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                    ),
                    Text(
                      'Compare',
                      style: TextStyle(
                          fontSize: 20,
                          color: ColorUtils.blackColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Expanded(
              //   flex: 1,
              //   child: ListView(
              //     scrollDirection: Axis.vertical,
              //     // crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       Row(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: <Widget>[
              //           Container(
              //             decoration: BoxDecoration(
              //                 color: Colors.white,
              //                 border: Border(
              //                     right: BorderSide(
              //                         color: ColorUtils.blueThemeColor,
              //                         width: 0.2))),
              //             padding: EdgeInsets.all(5),
              //             // width: 150,
              //             child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: titleList.map((String value) {
              //                   var index = titleList.indexOf(value);
              //                   return index == 0
              //                       ? Column(
              //                           children: <Widget>[
              //                             Container(
              //                               margin: EdgeInsets.only(left: 10),
              //                               height: 40,
              //                               child: Center(
              //                                 child: Text(
              //                                   value,
              //                                   style: TextStyle(
              //                                       fontSize: 16,
              //                                       color: ColorUtils
              //                                           .blueThemeColor,
              //                                       fontWeight:
              //                                           FontWeight.w500),
              //                                 ),
              //                               ),
              //                             ),
              //                             Container(
              //                                 margin: EdgeInsets.only(top: 10),
              //                                 height: 0.2,
              //                                 color: ColorUtils.blueThemeColor
              //                                     .withOpacity(0.5))
              //                           ],
              //                         )
              //                       : Column(
              //                           crossAxisAlignment:
              //                               CrossAxisAlignment.start,
              //                           children: <Widget>[
              //                             Container(
              //                               padding: const EdgeInsets.only(
              //                                   top: 4.4, left: 10),
              //                               child: Text(
              //                                 value,
              //                                 maxLines: 1,
              //                                 overflow: TextOverflow.clip,
              //                                 style: TextStyle(
              //                                   fontSize: 11,
              //                                   color: ColorUtils.darkGrey,
              //                                   fontWeight: FontWeight.w700,
              //                                 ),
              //                               ),
              //                             ),
              //                             Container(
              //                                 margin: EdgeInsets.only(top: 10),
              //                                 height: 0.2,
              //                                 color: ColorUtils.blueThemeColor)
              //                           ],
              //                         );
              //                 }).toList()),
              //           ),
              //           Expanded(
              //             flex: 2,
              //             child: Container(
              //               height: screenHeight,
              //               child: ListView.builder(
              //                 physics: ClampingScrollPhysics(),
              //                 scrollDirection: Axis.horizontal,
              //                 shrinkWrap: true,
              //                 itemCount: valuesList.length,
              //                 itemBuilder: (context, index) {
              //                   return Container(
              //                     width: screenWidth / 2,
              //                     padding: EdgeInsets.only(
              //                         left: 0, right: 0, top: 5, bottom: 5),
              //                     decoration: BoxDecoration(
              //                         color: Colors.white,
              //                         border: Border(
              //                             right: BorderSide(
              //                                 color: ColorUtils.blueThemeColor,
              //                                 width: 0.2))),
              //                     child: Column(
              //                         // mainAxisSize: MainAxisSize.min,
              //                         crossAxisAlignment:
              //                             CrossAxisAlignment.start,
              //                         children:
              //                             valuesList[index].map((String value) {
              //                           var ii =
              //                               valuesList[index].indexOf(value);
              //                           return ii != 0
              //                               ? Container(
              //                                   child: Expanded(
              //                                     flex: 1,
              //                                     child: Column(
              //                                       crossAxisAlignment:
              //                                           CrossAxisAlignment
              //                                               .start,
              //                                       children: <Widget>[
              //                                         value.length > 50
              //                                             ? Row(
              //                                                 children: <
              //                                                     Widget>[
              //                                                   Container(
              //                                                     padding: const EdgeInsets
              //                                                             .only(
              //                                                         top: 5,
              //                                                         left: 10),
              //                                                     child: Text(
              //                                                       value
              //                                                           .substring(
              //                                                               0,
              //                                                               22),
              //                                                       maxLines: 1,
              //                                                       overflow:
              //                                                           TextOverflow
              //                                                               .clip,
              //                                                       style:
              //                                                           TextStyle(
              //                                                         fontSize:
              //                                                             11,
              //                                                         color: ColorUtils
              //                                                             .darkGrey,
              //                                                         fontWeight:
              //                                                             FontWeight
              //                                                                 .w400,
              //                                                       ),
              //                                                     ),
              //                                                   ),
              //                                                   SizedBox(
              //                                                     width: 5,
              //                                                   ),
              //                                                   Container(
              //                                                     padding: const EdgeInsets
              //                                                             .only(
              //                                                         top: 5,
              //                                                         left: 10),
              //                                                     child:
              //                                                         Material(
              //                                                       color: Colors
              //                                                           .transparent,
              //                                                       child:
              //                                                           InkWell(
              //                                                         onTap:
              //                                                             () {
              //                                                               showAlert(appName, value);
              //                                                             },
              //                                                         child:
              //                                                             Text(
              //                                                           "Read more",
              //                                                           style:
              //                                                               TextStyle(
              //                                                             fontSize:
              //                                                                 11,
              //                                                             color:
              //                                                                 ColorUtils.blueThemeColor,
              //                                                             fontWeight:
              //                                                                 FontWeight.w700,
              //                                                           ),
              //                                                         ),
              //                                                       ),
              //                                                     ),
              //                                                   )
              //                                                 ],
              //                                               )
              //                                             : Container(
              //                                                 padding:
              //                                                     const EdgeInsets
              //                                                             .only(
              //                                                         top: 5,
              //                                                         left: 10),
              //                                                 child: Text(
              //                                                   value,
              //                                                   maxLines: 1,
              //                                                   overflow:
              //                                                       TextOverflow
              //                                                           .clip,
              //                                                   style:
              //                                                       TextStyle(
              //                                                     fontSize: 11,
              //                                                     color: ColorUtils
              //                                                         .darkGrey,
              //                                                     fontWeight:
              //                                                         FontWeight
              //                                                             .w400,
              //                                                   ),
              //                                                 ),
              //                                               ),
              //                                         Container(
              //                                             margin:
              //                                                 EdgeInsets.only(
              //                                                     top: 5),
              //                                             height: 0.2,
              //                                             color: ColorUtils
              //                                                 .blueThemeColor)
              //                                       ],
              //                                     ),
              //                                   ),
              //                                 )
              //                               : Column(
              //                                   crossAxisAlignment:
              //                                       CrossAxisAlignment.start,
              //                                   children: <Widget>[
              //                                     Container(
              //                                       height: 40,
              //                                       child: Image.asset(
              //                                           AssetUtils.icici_pru),
              //                                     ),
              //                                     Container(
              //                                         margin: EdgeInsets.only(
              //                                             top: 10),
              //                                         height: 0.8,
              //                                         color: ColorUtils.darkGrey
              //                                             .withOpacity(0.5))
              //                                   ],
              //                                 );
              //                         }).toList()),
              //                   );
              //                 },
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                child: Container(
                  color: ColorUtils.darkGrey.withOpacity(0.01),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(                            
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildTitles(),
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildRows(20),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
