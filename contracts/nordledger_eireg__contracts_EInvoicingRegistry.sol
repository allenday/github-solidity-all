pragma solidity ^0.4.4;

/**
* Registry of e-invoicing addresses as Solidity smart contract.
*/
contract EInvoicingRegistry {

    enum ContentType {

        Undefined,

        /** XML as defined in PEPPOL */
        InvoiceContactInformation,

        /** Direct YTJ / other national import */
        NationalBusinessRegistryData,

        /** Data operator wants to expose to others */
        OperatorPublicData,

        /** Data as defined in current TIEKE */
        TiekeCompanyData,

        /** Data as defined in current TIEKE */
        TiekeAddressData

    }

    struct InvoicingAddressInformation {

        /* Who can modify this invoicing address as a
           list of Ethereum addresses (public keys).
           Contains one entry, the public key of operator. */
        address[] owners;

        /* Company this invoicing address belongs to. Can be empty. */
        string vatId;

        /* Different information attached to this invoicing address.
           Key as ContentType.
         */
        mapping(uint=>string) data;
    }


    /* Business owner set tables what addresses he/she wants to use */
    struct RoutingInformation {

        /* Who can modify busines owner preferred routing.
           list of Ethereum addresses (public keys).
           Contains one entry, the public key of business owner. */
        address[] owners;

        /* Different information attached to this invoicing address  */
        mapping(uint=>string) data;
    }

    struct Company {

        /* Who can update company businessInformation (Contains one key, from YTJ) */
        address[] owners;

        /** List of different business core information data.
            Key as ContentType enum. */
        mapping(uint => string) businessInformation;

        /* Routing information as set by the business owner. */
        RoutingInformation routingInformation;

        /** Map of invoicing address (normalized) to their descriptions.
         *
         * Invoicing address as ASCII string with protocol.
         * Examples:
         *     IBAN:FI6213763000140986
         *     OVT:3705090754
         *
         */

        /* All invoicing addresses as a list, because map keys are not iterable in Solidity */
        string[] allInvoicingAddresses;
    }

    string public version = "0.3";

    /** How owns this contract and can add companies */
    address master;

    /**
     * Map VAT IDs to company records.
     *
     * Key is international Y-Tunnus (FI12312345).
     *
     */
    mapping(string => Company) vatIdRegistry;

    /**
     * Map invoicing address to data behind it
     */
    mapping(string=>InvoicingAddressInformation) invoicingAddressRegistry;

    /**
     * Vat id to company preferences to mappings.
     *
     * Company preferences is JSON encoded string.
     */
    mapping(string=>string) companyPreferencesRegistry;


    /**
     * Store data of all invoices.
     *
     */
    mapping(string=>string) invoiceRegistry;

    /**
     * Events that smart contracts post to blockchain, so that various listening
     * services can easily detect modifications.
     *
     * These events are indexable by Ethereum node and you can directly query them in JavaScript.
     */
    event CompanyCreated(string vatId);
    event CompanyUpdated(string vatId);
    event CompanyPreferencesUpdated(string vatId);
    event InvoicingAddressCreated(string invoicingAddress);
    event InvoicingAddressUpdated(string invoicingAddress);

    event InvoiceSent(string indexed toInvoiceAddress, string indexed fromInvoiceAddress, string invoiceId);

    /**
     * Constructor parameterless.
     */
    function EInvoicingRegistry() {
        master = msg.sender;
    }

    /**
     * Check if we have already imported company core data.
     */
    function hasCompany(string vatId) public constant returns (bool) {
        return vatIdRegistry[vatId].owners.length > 0;
    }

    /**
     * Return VAT ID for a given invoicing address.
     *
     * If not match return empty string.
     */
    function getVatIdByAddress(string invoicingAddress) public constant returns (string) {
        return invoicingAddressRegistry[invoicingAddress].vatId;
    }

    function createCompany(string vatId) public {

        if(bytes(vatId).length == 0) {
            throw; // Bad data
        }

        // Check if this party is allowed to update company core data (msg.sender = YTJ only)
        if(!canUpdateCompany(vatId, msg.sender)) {
            throw;
        }

        vatIdRegistry[vatId].owners.push(msg.sender);
        CompanyCreated(vatId);
    }

    function createInvoicingAddress(string vatId, string invoicingAddress) public {

        if(bytes(vatId).length == 0 || bytes(invoicingAddress).length == 0) {
            throw; // Bad data
        }

        if(!canUpdateInvoicingAddress(invoicingAddress, msg.sender)) {
            throw;
        }

        // Become owner
        Company company = vatIdRegistry[vatId];
        InvoicingAddressInformation info = invoicingAddressRegistry[invoicingAddress];

        if(info.owners.length > 0) {
            throw; // Already created
        }

        info.owners.push(msg.sender);

        // Backwards mapping invoicing address -> VAT ID
        invoicingAddressRegistry[invoicingAddress].vatId =  vatId;

        // List of all registered addresses for this company
        if(company.owners.length > 0) {
            company.allInvoicingAddresses.push(invoicingAddress);
        }

        // Notify new address created
        InvoicingAddressCreated(invoicingAddress);
    }

    function setCompanyData(string vatId, ContentType contentType, string data) public {

        if(bytes(vatId).length == 0 || bytes(data).length == 0) {
            throw; // Bad data
        }

        // Check if this party is allowed to update company core data (msg.sender = YTJ only)
        if(!canUpdateCompany(vatId, msg.sender)) {
            throw;
        }

        vatIdRegistry[vatId].businessInformation[uint(contentType)] = data;

        CompanyUpdated(vatId);
    }

    // TODO: Do combined createAddress + setInvoicingAddressData to reduce latencies
    function setInvoicingAddressData(string vatId, string invoicingAddress, ContentType contentType, string data) public {

        if(!canUpdateInvoicingAddress(invoicingAddress, msg.sender)) {
            throw;
        }

        invoicingAddressRegistry[invoicingAddress].data[uint(contentType)] = data;
        invoicingAddressRegistry[invoicingAddress].vatId = vatId;

        InvoicingAddressUpdated(invoicingAddress);
    }

    function getBusinessInformation(string vatId, ContentType contentType) public constant returns(string) {
        return vatIdRegistry[vatId].businessInformation[uint(contentType)];
    }

    /**
     * Return all addresses for a company.
     *
     * TODO: Current Solidity does not allow to return string[] over a transaction
     */
    function getInvoicingAddressCount(string vatId) public constant returns(uint) {

        Company company = vatIdRegistry[vatId];

        if(company.owners.length == 0) {
            throw; // Not created yet
        }

        return company.allInvoicingAddresses.length;
    }

    /**
     * Return all addresses for a company.
     *
     * TODO: Current Solidity does not allow to return string[] over a transaction
     */
    function getInvoicingAddressByIndex(string vatId, uint idx) public constant returns(string) {

        Company company = vatIdRegistry[vatId];

        if(company.owners.length == 0) {
            throw; // Not created yet
        }

        return company.allInvoicingAddresses[idx];
    }

    function getAddressInformation(string invoicingAddress, ContentType contentType) public constant returns(string) {
        return invoicingAddressRegistry[invoicingAddress].data[uint(contentType)];
    }

    /**
     * Company owner can update their preferences.
     */
    function updateRoutingPreference(string vatId, string preferences) public {

        if(!canUpdateCompanyPreferences(vatId, msg.sender)) {
            throw;
        }

        companyPreferencesRegistry[vatId] = preferences;
    }

    /**
     * Get routing preferences set by the company owner.
     *
     */
    function getCompanyPreferences(string vatId) public constant returns (string) {
        return companyPreferencesRegistry[vatId];
    }

    /**
     * Only registry master key can add companies.
     */
    function canUpdateCompany(string vatId, address sender) public constant returns (bool) {
        return sender == master;
    }

    /**
     * Invoicing address operators can update data behind id.
     */
    function canUpdateInvoicingAddress(string invoicingAddress, address sender) public constant returns (bool) {
        return true;
    }

    /**
     * Invoicing address operators can update data behind id.
     */
    function canUpdateCompanyPreferences(string vatId, address sender) public constant returns (bool) {
        return true;
    }

    /**
     * Demo invoice send function.
     *
     * Does not encrypt payload - in real environment we need the public key of the receiver.
     *
     * Does not check permissions.
     */
    function sendInvoice(string toInvoiceAddress, string fromInvoiceAddress, string invoiceId, string payload) {
        invoiceRegistry[invoiceId] = payload;
        InvoiceSent(toInvoiceAddress, fromInvoiceAddress, invoiceId);
    }

    /**
     * Return demo invoice payload.
     *
     */
    function getInvoice(string invoiceId) public returns (string) {
        return invoiceRegistry[invoiceId];
    }

}
