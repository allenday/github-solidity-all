pragma solidity ^0.4.11;

/*
 * This file contains a set of contracts used to handle consents between a company
 * and a person.
 *
 * Copyright 2017 Tomas Stenlund, tomas.stenlund@telia.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/*
 * This is the contract that handles consent templates for a specific purpouse. It is used
 * when a person or entity wants to get a consent from another user. The consent is then
 * generated from this template.
 *
 * It basically provides a textual description of the consent.
 *
 */
contract ConsentTemplate {

  address private owner;        /* The owner of the template */
  address private creator;      /* Creator of this template */
  string  private purpouse;     /* What purpouse the template is for */
  string  private company;      /* The name of the owner */
  uint    private version;      /* Version of the purpouse, i.e. if the text or title changes for the same purpouse */
  string  private title;        /* The title of the consent */
  string  private text;         /* The text that describes the purpouse of the consent */
  string  private languageCountry;       /* The language and country the consent template is valid for.
					  *
					  * Standard country-language code according to ISO 639 and ISO 3166-1 alpha 2
					  * separated by a dash, so for swedish in Sweden it is "sv-SE" */

  /* Creates the contract and set the values of the contract. */
  function ConsentTemplate (string _company, string _purpouse, uint _version, string _title, string _text, string _languageCountry) public
  {
    owner = tx.origin;
    creator = msg.sender;
    company = _company;
    purpouse = _purpouse;
    version = _version;
    title = _title;
    text = _text;
    languageCountry = _languageCountry;
  }

  /* Set of getters for the contract */
  function getVersion () public constant returns (uint)
  {
    return version;
  }

  function getTitle () public constant returns (string)
  {
    return title;
  }

  function getPurpouse () public constant returns (string)
  {
    return purpouse;
  }
  
  function getText () public constant returns (string)
  {
    return text;
  }

  function getLanguageCountry () public constant returns (string)
  {
    return languageCountry;
  }

  function getCompany() public constant returns (string)
  {
    return company;
  }
  
}

/*
 * This is the contract that handles consents for a specific purpouse given by a
 * user (giver) to another user (owner).
 *
 * It basically provides a textual description  that is either accepted or denied by a user.
 *
 */
contract Consent {

    /* Enumeration for the state of the consent */
  enum Status {denied,    /* The giver has denied the consent */
	       accepted,  /* The giver has accepted the consent */ 
	       requested, /* The company has requested a consent, user has not yet responded */
	       cancelled  /* The company has cancelled the consent because he no longer needs it */
  }
    
  /* State variables for the contract */
  address private owner;  /* Who issues to consent form */
  address private creator; /* Who created this object */
  address private giver;  /* Who gives the consent, address to the account. */
  Status  private status; /* The status of the consent */
  address private consentTemplate; /* The template this consent is based on */
  
  /* Event to signal that the status has changed */
  event ConsentStatusChanged (address indexed consent, address indexed owner, address indexed giver, Status status);

  /* A modifier */
  modifier onlyBy(address _account)
  {
    require(tx.origin == _account);
    _;
  }
  
  /* This function is executed at initialization and sets the owner and the giver of the consent */
  /* as well as what it contains */
  function Consent(address _giver, address _consentTemplate) public
  {
    giver = _giver;
    owner = tx.origin;
    creator = msg.sender;
    consentTemplate = _consentTemplate;
    status = Status.requested;
  }

  /* Sets the status of the consent, this can only be done by the giver. */
  function setStatus(Status _status) onlyBy (giver) public
  {
    if (_status == Status.denied || _status == Status.accepted) {
      status = _status;
      ConsentStatusChanged (this, owner, giver, _status);
    }
  }

  /* Cancels a consent, this can only be done by the company who created the consent. */
  function cancel () onlyBy (owner) public
  {
    status = Status.cancelled;
    ConsentStatusChanged (this, owner, giver, Status.cancelled);
  }
  
  /* Returns the status of the consent */    
  function getStatus() public constant returns (Status)
  {
    return status;
  }

  /* Returns the consent template that this consent is based on */
  function getTemplate() public constant returns (ConsentTemplate)
  {
    return ConsentTemplate(consentTemplate);
  }

  /* Returns with the giver */
  function getGiver() public constant returns (address)
  {
    return giver;
  }
  
  /* Returns with teh giver */
  function getOwner() public constant returns (address)
  {
    return owner;
  }
  
  /* Function to recover the funds on the contract */
  function kill() { if (tx.origin == owner) selfdestruct(owner); }
}

/*
 * This a list of consents that are offered to a specific account.
 *
 * This contains a list of consents that a specific user has been
 * offered. Regardless if it is deined, approved or has no decision.
 *
 */
contract ConsentFile {

  /* The owner of the file */
  address private owner;
  address private creator;
  address private giver;
  
  /* The list of all consents */
  address[] private listOfConsents;

  /* Events that are sent when things happen */
  event ConsentFileConsentAdded (address indexed file, address indexed owner, address indexed giver, address consent);

  /* A modifier */
  modifier onlyBy(address _account)
  {
    require(tx.origin == _account);
    _;
  }
  
  /* The constructor of the file. Also attaches it to an owner */
  function ConsentFile (address _giver) public
  {
    owner = tx.origin;
    creator = msg.sender;
    giver = _giver;
  }

  /* Adds a new consent to the file */
  function addConsent (address _consent) public 
  {
    listOfConsents.push (_consent);
    ConsentFileConsentAdded (this, owner, giver, _consent);
  }

  /* Retrieve a list of all consents in the file */
  function getListOfConsents () public constant returns (address[])
  {
    return listOfConsents;
  }

  /* Retrieves the owner */
  function getGiver () public constant returns (address)
  {
    return giver;
  }
  
}

/* 
 * This is the consent factory contract that handles consents and version of
 * consents.
 *
 * It basically provides an interface to be able to create consents based on
 * a specific purpouse for a specific user. And always using the latest version
 * and always puts newly generated consents into a persons consent file.
 *
 */
contract ConsentFactory {

  /* Enumeration for errors */
  enum Error {no_such_template, /* If no such template exists for the purpouse, language and country */
	      only_accepted_or_denied /* Tried to set wrong status on consent */
  }
  
  /* The owner of this contract */
  address private owner;  /* Who owns this Consent Facotory, this is a company */
  address private creator; /* Who created this factory */
  string  private company;  /* Company that created this */
  
  /* List of all templates in this factory */
  address[] private listOfAllConsentTemplates;
  address[] private listOfActiveConsentTemplates;
  
  /* Contains a map from purpouse to language and country mapping to index into the list of active consent templates */
  mapping (string => mapping (string => uint)) private consentTemplates;
  
  /* Events generated when the consent has been created */
  event ConsentFactoryConsentCreatedEvent(address indexed factory, address indexed owner, address indexed user, address file, address consent);
  event ConsentFactoryFileCreatedEvent(address indexed factory, address indexed owner, address indexed user, address file);
  event ConsentFactoryFailedEvent(address indexed factory, address indexed owner, address indexed user, Error error);
  event ConsentFactoryTemplateAddedEvent (address indexed factory, address indexed owner, address template);
  event ConsentFactoryConsentStatusChangedEvent (address indexed factory, address indexed owner, address indexed user, Consent consent, Consent.Status status);
  
  /* A modifier */
  modifier onlyBy(address _account)
  {
    require(tx.origin == _account);
    _;
  }
  
  /* Constructor for the consent factory */
  function ConsentFactory(string _company, address _owner) public
  {
    owner = _owner;
    creator = msg.sender;
    company = _company;
  }

  /* Adds a consent template to the factory to be used for consent generation. Should have a modifier for the company. */
  function addConsentTemplate (string _purpouse, uint _version, string _title, string _text, string _languageCountry) public
  {
    /* Add the template for the specific language, country and purpouse */
    uint ix = consentTemplates[_purpouse][_languageCountry];
    address ct = new ConsentTemplate (company, _purpouse, _version, _title, _text, _languageCountry);
    if (ix == 0) {
      ix = listOfActiveConsentTemplates.push (ct);
      consentTemplates[_purpouse][_languageCountry] = ix;
    } else {
      listOfActiveConsentTemplates[ix-1] = ct;
    }
    listOfAllConsentTemplates.push(ct);
    ConsentFactoryTemplateAddedEvent (this, owner, ct);    
  }

  /* Returns with a list of active consent templates */
  function getActiveConsentTemplates() onlyBy (owner) public constant returns (address[])
  {
    return listOfActiveConsentTemplates;
  }
  
  /* Returns with a list of all consent templates */
  function getAllConsentTemplates() onlyBy (owner) public constant returns (address[])
  {
    return listOfAllConsentTemplates;
  }
  
  /* Create a file that holds a users all consents.
   * 
   * This is the file that holds all consents regardless of their state. Should have a modifier for the company.
   */
  function createConsentFile (address _user) onlyBy (owner) public
  {
    address file = new ConsentFile (_user);
    ConsentFactoryFileCreatedEvent(this, owner, _user, file);
  }
  
  /* Create a consent for a specific purpouse of the latest version, language and country.
   *
   * Country and Purpouse must exist otherwise it will fail, if language is not there it will
   * default to countrys default language if it exists otherwise it will fail. It adds
   * the consent to the users file as well. Should have a modifier for the company only.
   */
  function createConsent (address _file, string _purpouse, string _languageCountry) onlyBy (owner) public
  {
    ConsentFile cf = ConsentFile (_file);
    ConsentTemplate ct = getTemplate (_purpouse, _languageCountry);
    if (ct != address(0)) {

      /* We got a template so generate the consent and put it into the consent file */
      Consent consent = new Consent (cf.getGiver(), ct);
      ConsentFile(_file).addConsent (consent);
      ConsentFactoryConsentCreatedEvent(this, owner, cf.getGiver(), _file, consent);

    } else {
      
      ConsentFactoryFailedEvent(this, owner, cf.getGiver(), Error.no_such_template);
      
    }
  }
  
  /* This function tests wether a consent for a specific purpouse exists or not */
  function getTemplate (string _purpouse, string _languageCountry) constant internal returns (ConsentTemplate)
  {
    /* Get the consents for a specific purpouse and language, country*/
    uint ix = consentTemplates[_purpouse][_languageCountry];
    if (ix == 0) {
      
      /* Fallback here is to only go for the default language of the country */
      /* So we need to strip the language from the country */
      bytes memory b = bytes (_languageCountry);
      if (b.length==5) {
	if (b[2] == 45) {
    	  bytes memory c = new bytes(2);
	  
	  /* Get the country */
    	  c[0] = b[3];
    	  c[1] = b[4];
    	  ix = consentTemplates[_purpouse][string(c)];
    	}
      }
    }

    /* Return the consent template if we found any */
    if (ix>0)
      return ConsentTemplate(listOfActiveConsentTemplates[ix-1]);
    else
      return ConsentTemplate(address(0));
  }

  /* Change the status of the consent */
  function setConsentStatus(Consent _consent, Consent.Status _status) onlyBy (_consent.getGiver()) public
  {
    if(_status == Consent.Status.accepted || _status == Consent.Status.denied) {
      _consent.setStatus (_status);
      ConsentFactoryConsentStatusChangedEvent (this, _consent.getOwner(), _consent.getGiver(), _consent, _status);
    } else {
      ConsentFactoryFailedEvent (this, _consent.getOwner(), _consent.getGiver(), Error.only_accepted_or_denied);
    }
  }
  
  /* Cancel the consent */
  function cancelConsent(Consent _consent) onlyBy (_consent.getOwner()) public
  {
    _consent.cancel();
    ConsentFactoryConsentStatusChangedEvent (this, _consent.getOwner(), _consent.getGiver(), _consent, Consent.Status.cancelled);
  }

  /* The company who has this factory */
  function getCompany() public constant returns (string)
  {
    return company;
  }

  /* Returns the owner for the factory */
  function getOwner() public constant returns (address)
  {
    return owner;
  }
  
  /* Function to recover the funds on the contract */
  function kill() { if (msg.sender == owner) selfdestruct(owner); }
}

/*
 * END
 */
