public inherited sharing class Dml {
    public enum Operation {
        INSERT_RECORDS,
        UPDATE_RECORDS,
        UPSERT_RECORDS,
        DELETE_RECORDS,
        UNDELETE_RECORDS
    }

    @TestVisible
    private static final Boolean DEFAULT_ALL_OR_NONE = true;
    @TestVisible
    private static final AccessLevel DEFAULT_ACCESS_LEVEL = AccessLevel.USER_MODE;

    @TestVisible
    private Operation dmlOperation;
    @TestVisible
    private List<SObject> records;
    @TestVisible
    private List<Id> recordIds;
    @TestVisible
    private SObjectField externalIdField;
    @TestVisible
    private Boolean allOrNone;
    @TestVisible
    private AccessLevel accessLevel;

    public Dml(Operation dmlOperation, SObject record) {
        this(dmlOperation, new List<SObject>{ record });
    }

    public Dml(Operation dmlOperation, List<SObject> records) {
        this.dmlOperation = dmlOperation;
        this.records = records;
        this.allOrNone = DEFAULT_ALL_OR_NONE;
        this.accessLevel = DEFAULT_ACCESS_LEVEL;
    }

    public Dml(Operation dmlOperation, Id recordId) {
        this(dmlOperation, new List<Id>{ recordId });
    }

    public Dml(Operation dmlOperation, Set<Id> recordIds) {
        this(dmlOperation, new List<Id>(recordIds));
    }

    public Dml(Operation dmlOperation, List<Id> recordIds) {
        if (dmlOperation != Operation.DELETE_RECORDS && dmlOperation != Operation.UNDELETE_RECORDS) {
            throw new IllegalArgumentException('Record IDs can only be set delete and undelete operations');
        }

        this.dmlOperation = dmlOperation;
        this.recordIds = recordIds;
        this.allOrNone = DEFAULT_ALL_OR_NONE;
        this.accessLevel = DEFAULT_ACCESS_LEVEL;
    }

    public Dml withExternalIdField(SObjectField externalIdField) {
        if (this.dmlOperation != Operation.UPSERT_RECORDS) {
            throw new IllegalArgumentException('The externalIdField can only be set on upsert records');
        }

        this.externalIdField = externalIdField;
        return this;
    }

    public Dml withAllOrNone(Boolean allOrNone) {
        this.allOrNone = allOrNone;
        return this;
    }

    public Dml withAccessLevel(AccessLevel accessLevel) {
        this.accessLevel = accessLevel;
        return this;
    }

    public Operation getOperation() {
        return this.dmlOperation;
    }

    public List<SObject> getRecords() {
        return this.records;
    }

    public List<Id> getRecordIds() {
        return this.recordIds;
    }

    public SObjectField getExternalIdField() {
        return this.externalIdField;
    }

    public Boolean getAllOrNone() {
        return this.allOrNone;
    }

    public AccessLevel getAccessLevel() {
        return this.accessLevel;
    }
}