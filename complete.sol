// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

struct bugReport {
    string bugTitle;
    string bugDescription;
    string bugPriority;
}

struct featureReport {
    string featureTitle;
    string featureDescription;
    string featurePriority;
}

struct listOfBnF {
    string timeofReport;
    string patchName;
    string patchDescription;
    string vno;
    bugReport[] bugRequest;
    featureReport[] featureRequest;
    bool deployed;
    int uploaded;
    int approved;
    string filename;
    bytes patch;
}

contract PatchDevelopment{
    string timeofRequest;
    bugReport[] public bugs_arr;
    featureReport[] public features_arr;
    bugReport[] public unselectedBugs;
    featureReport[] public unselectedFeatures;
    bool public submittedbyadmin;
    mapping(string => listOfBnF) public requests;
    string[] patchnames;

    // Used by reporter to submit bugs
    function toAdmin(string memory time, string[][] memory new_b,string[][] memory new_f) public{
        timeofRequest = time;
        submittedbyadmin = false;
        delete bugs_arr;
        for(uint i=0;i<new_b.length;i++){
            bugReport memory temp = bugReport(new_b[i][0], new_b[i][1], new_b[i][2]);
            bugs_arr.push(temp);
        }
        delete features_arr;
        for(uint i=0;i<new_f.length;i++){
            featureReport memory temp = featureReport(new_f[i][0], new_f[i][1], new_f[i][2]);
            features_arr.push(temp);
        }
    }

    // Used by Admin to read reports
    function send_list() public view returns(bugReport[] memory, featureReport[] memory ){
        if(submittedbyadmin==false){
        return (bugs_arr,features_arr);
        }
        else{
            bugReport[] memory temp1;
            delete temp1;
            featureReport[] memory temp2;
            delete temp2;
            return(temp1, temp2);
        }
    }
    function previousReq() public view returns(bugReport[] memory, featureReport[] memory ){
        return (unselectedBugs,unselectedFeatures);
    }

    // Used by admin to submit unchecked list
    function unChecked(string[][] memory new_b,string[][] memory new_f) internal{
        delete unselectedBugs;
        submittedbyadmin = true;
        for(uint i=0;i<new_b.length;i++){
            bugReport memory temp = bugReport(new_b[i][0], new_b[i][1], new_b[i][2]);
            unselectedBugs.push(temp);
        }
        delete unselectedFeatures;
        
        for(uint i=0;i<new_f.length;i++){
            featureReport memory temp = featureReport(new_f[i][0], new_f[i][1], new_f[i][2]);
            unselectedFeatures.push(temp);
        }
    }

    // Admin uses this to submit to developer
    function fromAdmin(string memory time_rn, string memory pname, string memory pdesc, string[][] memory bugs, string[][] memory features, string[][] memory bugsUn, string[][] memory featuresUn) public {
        
        unChecked(bugsUn, featuresUn);
        listOfBnF storage temporary = requests[pname];
        patchnames.push(pname);
        temporary.patchName = pname;
        temporary.patchDescription = pdesc;
        temporary.approved = 0;
        temporary.deployed = false;
        temporary.uploaded = 0;
        temporary.timeofReport = time_rn;

        for (uint i = 0; i < bugs.length; i++) {
            bugReport memory bugTemp =  bugReport(bugs[i][0], bugs[i][1], bugs[i][2]);
            temporary.bugRequest.push(bugTemp);
        }
        
        for (uint i = 0; i < features.length; i++) {
            featureReport memory featureTemp = featureReport(features[i][0], features[i][1], features[i][2]);
            temporary.featureRequest.push(featureTemp);
        }
    }

    // Developer uses this function to see what came from admin
    function getRequests() public view returns (listOfBnF[] memory) {
        listOfBnF[] memory result = new listOfBnF[](patchnames.length);

        for (uint i = 0; i < patchnames.length; i++) {   
            result[i] = requests[patchnames[i]];
        }

        return result;
    }

    // Used by Developer to submit the patch
    function uploadedbyDev(string memory time_rn, string memory pname, string memory ver, string memory fileName, bytes memory _patch) public{
        listOfBnF storage temp = requests[pname];
        temp.timeofReport = time_rn;
        temp.vno = ver;
        temp.filename = fileName;
        temp.patch = _patch;
        temp.uploaded = 1;
    }

    // Used by QA to see the patches uploaded by Developer
    // Also used by the Admin before deployment
    function getfromDev() public view returns (listOfBnF[] memory) {
        listOfBnF[] memory result = new listOfBnF[](patchnames.length);

        for (uint i = 0; i < patchnames.length; i++) {   
            result[i] = requests[patchnames[i]];
        }

        return result;
    }

    // Approval given by QA
    function approval(string memory time_rn, int status, string memory pname) public{
        listOfBnF storage temp1 = requests[pname];
        temp1.approved = status;
        temp1.uploaded = status;
        temp1.timeofReport = time_rn;
    }
    
    // used by admin for deployment 
    function deployment(string memory time_rn, string memory pname, bool status) public{
        listOfBnF storage temp = requests[pname];
        temp.deployed = status;
        temp.timeofReport = time_rn;

    }

    // Used by the User to get the patches
    function newPatches() public view returns(listOfBnF[] memory){
        listOfBnF[] memory result = new listOfBnF[](patchnames.length);
        uint j=0;
        for (uint i = 0; i < patchnames.length; i++) { 
            if(requests[patchnames[i]].deployed){
            result[j] = requests[patchnames[i]];
            j++;
            }
        }

        return result;
    }
}