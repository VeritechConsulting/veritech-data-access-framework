// Suppressing MethodNamingConventions because naming format is methodBeingTested_testScenario_expectedResult
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest(IsParallel=true)
private without sharing class DmlTest {
    //================================================================================
    // Helpers
    //================================================================================

    static Integer fakeIdCounter = 1;

    static Id generateFakeId(SObjectType objectType) {
        String objectPrefix = objectType.getDescribe().getKeyPrefix();
        String fakeIdCounterStr = String.valueOf(fakeIdCounter++);
        Id fakeId = Id.valueOf(objectPrefix + '0'.repeat(12 - fakeIdCounterStr.length()) + fakeIdCounterStr);
        return fakeId;
    }

    //================================================================================
    // Unit tests
    //================================================================================

    @IsTest
    static void dml_passSingleRecord_dmlConstructed() {
        Dml.Operation operation = Dml.Operation.INSERT_RECORDS;
        Account record = new Account();

        Test.startTest();
        Dml dmlInstance = new Dml(operation, record);
        Test.stopTest();

        Assert.areEqual(
            operation,
            dmlInstance.dmlOperation,
            'Expected the instance\'s operation to match the value passed'
        );
        Assert.areEqual(1, dmlInstance.records.size(), 'Expected the instance to contain one record');
        Assert.areEqual(record, dmlInstance.records.get(0), 'Expected the instance to contain the account passed');
        Assert.areEqual(
            Dml.DEFAULT_ALL_OR_NONE,
            dmlInstance.allOrNone,
            'Expected the instance to contain the default allOrNone value'
        );
        Assert.areEqual(
            Dml.DEFAULT_ACCESS_LEVEL,
            dmlInstance.accessLevel,
            'Expected the instance to contain the default accessLevel value'
        );
    }

    @IsTest
    static void dml_passListOfRecords_dmlConstructed() {
        Dml.Operation operation = Dml.Operation.INSERT_RECORDS;
        List<Account> records = new List<Account>{ new Account() };

        Test.startTest();
        Dml dmlInstance = new Dml(operation, records);
        Test.stopTest();

        Assert.areEqual(
            operation,
            dmlInstance.dmlOperation,
            'Expected the instance\'s operation to match the value passed'
        );
        Assert.areEqual(1, dmlInstance.records.size(), 'Expected the instance to contain one record');
        Assert.areEqual(
            records.get(0),
            dmlInstance.records.get(0),
            'Expected the instance to contain the account passed'
        );
        Assert.areEqual(
            Dml.DEFAULT_ALL_OR_NONE,
            dmlInstance.allOrNone,
            'Expected the instance to contain the default allOrNone value'
        );
        Assert.areEqual(
            Dml.DEFAULT_ACCESS_LEVEL,
            dmlInstance.accessLevel,
            'Expected the instance to contain the default accessLevel value'
        );
    }

    @IsTest
    static void dml_passSingleId_dmlConstructed() {
        Dml.Operation dmlOperation = Dml.Operation.DELETE_RECORDS;
        Id recordId = generateFakeId(Account.SObjectType);

        Test.startTest();
        Dml dmlInstance = new Dml(dmlOperation, recordId);
        Test.stopTest();

        Assert.areEqual(dmlOperation, dmlInstance.dmlOperation, 'Expected the operation to match the value passed');
        Assert.areEqual(
            recordId,
            dmlInstance.recordIds.get(0),
            'Expected the instance to contain the Account Id passed'
        );

        Assert.areEqual(
            Dml.DEFAULT_ALL_OR_NONE,
            dmlInstance.allOrNone,
            'Expected the instance to contain the default allOrNone value'
        );

        Assert.areEqual(
            Dml.DEFAULT_ACCESS_LEVEL,
            dmlInstance.accessLevel,
            'Expected the instance to contain the default accessLevel value'
        );
    }

    @IsTest
    static void dml_passSetOfId_dmlConstructed() {
        Dml.Operation dmlOperation = Dml.Operation.DELETE_RECORDS;
        Set<Id> recordIds = new Set<Id>{ generateFakeId(Account.SObjectType) };

        Test.startTest();
        Dml dmlInstance = new Dml(dmlOperation, recordIds);
        Test.stopTest();

        Assert.areEqual(dmlOperation, dmlInstance.dmlOperation, 'Expected the operation to match the value passed');
        Assert.areEqual(
            new List<Id>(recordIds),
            dmlInstance.recordIds,
            'Expected the instance to contain the Account Ids passed'
        );

        Assert.areEqual(
            Dml.DEFAULT_ALL_OR_NONE,
            dmlInstance.allOrNone,
            'Expected the instance to contain the default allOrNone value'
        );

        Assert.areEqual(
            Dml.DEFAULT_ACCESS_LEVEL,
            dmlInstance.accessLevel,
            'Expected the instance to contain the default accessLevel value'
        );
    }

    @IsTest
    static void dml_passListOfId_dmlConstructed() {
        Dml.Operation dmlOperation = Dml.Operation.DELETE_RECORDS;
        List<Id> recordIds = new List<Id>{ generateFakeId(Account.SObjectType) };

        Test.startTest();
        Dml dmlInstance = new Dml(dmlOperation, recordIds);
        Test.stopTest();

        Assert.areEqual(dmlOperation, dmlInstance.dmlOperation, 'Expected the operation to match the value passed');
        Assert.areEqual(recordIds, dmlInstance.recordIds, 'Expected the instance to contain the Account Ids passed');

        Assert.areEqual(
            Dml.DEFAULT_ALL_OR_NONE,
            dmlInstance.allOrNone,
            'Expected the instance to contain the default allOrNone value'
        );

        Assert.areEqual(
            Dml.DEFAULT_ACCESS_LEVEL,
            dmlInstance.accessLevel,
            'Expected the instance to contain the default accessLevel value'
        );
    }

    @IsTest
    static void dml_passInvalidOperation_throwException() {
        Dml.Operation dmlOperation = Dml.Operation.UPDATE_RECORDS;
        List<Id> recordIds = new List<Id>{ generateFakeId(Account.SObjectType) };

        Test.startTest();
        try {
            new Dml(dmlOperation, recordIds);
            Assert.fail('The expected exception was not thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'The expected exception was not thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void withExternalIdField_dmlOperationIsNotUpsert_exceptionThrown() {
        Dml dmlInstance = new Dml(Dml.Operation.INSERT_RECORDS, new List<SObject>());

        Test.startTest();
        try {
            dmlInstance.withExternalIdField(null);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'The expected exception was not thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void withExternalIdField_dmlOperationIsUpsert_externalIdFieldSet() {
        Dml dmlInstance = new Dml(Dml.Operation.UPSERT_RECORDS, new List<SObject>());
        SObjectField externalIdField = Account.Name;

        Test.startTest();
        dmlInstance.withExternalIdField(externalIdField);
        Test.stopTest();

        Assert.areEqual(externalIdField, dmlInstance.externalIdField, 'Expected the externalIdField to be set');
    }

    @IsTest
    static void withAllOrNone_passValidAllOrNone_allOrNonePopulated() {
        Dml.Operation operation = Dml.Operation.INSERT_RECORDS;
        List<Account> records = new List<Account>{ new Account() };

        Boolean allOrNone = false;
        Dml dmlInstance = new Dml(operation, records);

        Test.startTest();
        dmlInstance.withAllOrNone(allOrNone);
        Test.stopTest();

        Assert.areEqual(
            allOrNone,
            dmlInstance.allOrNone,
            'Expected the instance\'s allOrNone to match the value passed'
        );
    }

    @IsTest
    static void withAccessLevel_passValidAccessLevel_accessLevelPopulated() {
        Dml.Operation operation = Dml.Operation.INSERT_RECORDS;
        List<Account> records = new List<Account>{ new Account() };

        AccessLevel accessLevel = AccessLevel.SYSTEM_MODE;
        Dml dmlInstance = new Dml(operation, records);

        Test.startTest();
        dmlInstance.withAccessLevel(accessLevel);
        Test.stopTest();

        Assert.areEqual(
            accessLevel,
            dmlInstance.accessLevel,
            'Expected the instance\'s accessLevel to match the value passed'
        );
    }

    @IsTest
    static void getOperation_noParameters_returnDmlOperation() {
        Dml.Operation operation = Dml.Operation.INSERT_RECORDS;
        Dml dmlInstance = new Dml(operation, new List<SObject>());

        Test.startTest();
        Dml.Operation operationReturned = dmlInstance.getOperation();
        Test.stopTest();

        Assert.areEqual(
            operation,
            operationReturned,
            'Expected the operation returned to be the same as the one passed'
        );
    }

    @IsTest
    static void getRecords_noParameters_returnRecords() {
        Dml.Operation operation = Dml.Operation.INSERT_RECORDS;
        List<SObject> records = new List<SObject>{ new Account(), new Account() };

        Dml dmlInstance = new Dml(operation, records);

        Test.startTest();
        List<SObject> recordsReturned = dmlInstance.getRecords();
        Test.stopTest();

        Assert.areEqual(records, recordsReturned, 'Expected the records returned to be the same as the one passed');
    }

    @IsTest
    static void getRecordIds_noParameters_returnExternalIdField() {
        Id recordId = generateFakeId(Account.SObjectType);
        Dml dmlInstance = new Dml(Dml.Operation.DELETE_RECORDS, recordId);

        Test.startTest();
        List<Id> recordIdsReturned = dmlInstance.getRecordIds();
        Test.stopTest();

        Assert.areEqual(
            new List<Id>{ recordId },
            recordIdsReturned,
            'Expected the recordIds returned to be the same as the one passed'
        );
    }

    @IsTest
    static void getExternalIdField_noParameters_returnExternalIdField() {
        Dml dmlInstance = new Dml(Dml.Operation.INSERT_RECORDS, new List<SObject>());
        dmlInstance.externalIdField = Account.Name;

        Test.startTest();
        SObjectField externalIdFieldReturned = dmlInstance.getExternalIdField();
        Test.stopTest();

        Assert.areEqual(
            dmlInstance.externalIdField,
            externalIdFieldReturned,
            'Expected the externalIdField returned to be the same as the one passed'
        );
    }

    @IsTest
    static void getAllOrNone_noParameters_returnAllOrNone() {
        Dml dmlInstance = new Dml(Dml.Operation.INSERT_RECORDS, new List<SObject>());
        dmlInstance.allOrNone = true;

        Test.startTest();
        Boolean allOrNoneReturned = dmlInstance.getAllOrNone();
        Test.stopTest();

        Assert.areEqual(
            dmlInstance.allOrNone,
            allOrNoneReturned,
            'Expected the allOrNone returned to be the same as the one passed'
        );
    }

    @IsTest
    static void getAccessLevel_noParameters_returnAccessLevel() {
        Dml dmlInstance = new Dml(Dml.Operation.INSERT_RECORDS, new List<SObject>());
        dmlInstance.accessLevel = AccessLevel.SYSTEM_MODE;

        Test.startTest();
        AccessLevel accessLevelReturned = dmlInstance.getAccessLevel();
        Test.stopTest();

        Assert.areEqual(
            dmlInstance.accessLevel,
            accessLevelReturned,
            'Expected the accessLevel returned to be the same as the one passed'
        );
    }
}