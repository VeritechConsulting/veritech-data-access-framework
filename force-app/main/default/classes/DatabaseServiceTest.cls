// Suppressing MethodNamingConventions because naming format is methodBeingTested_testScenario_expectedResult
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest(IsParallel=false)
private without sharing class DatabaseServiceTest {
    @TestSetup
    static void setupTestData() {
        // Create user
        Profile systemAdminProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ];

        Integer randomInt = Math.round(Math.random() * (99999 - 10000) + 10000);

        User testUser = new User(
            FirstName = 'Niels' + randomInt,
            LastName = 'Bohr' + randomInt,
            Email = 'niels.bohr' + randomInt + '@veritechconsulting.com',
            Username = 'niels.bohr' + randomInt + '@veritechconsulting.com',
            Alias = 'nielsboh',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = systemAdminProfile.Id
        );

        Database.insert(testUser);

        Account testAccount = new Account(Name = 'University of Copenhagen' + randomInt);
        Database.insert(testAccount);
    }

    @IsTest
    static void databaseService_noParameters_returnNewInstance() {
        Test.startTest();
        DatabaseService database = new DatabaseService();
        Test.stopTest();

        Assert.isNotNull(database, 'Expected the object to be not null');
    }

    @IsTest
    static void query_passSubselectQuery_exceptionThrown() {
        DatabaseService database = new DatabaseService();
        Query subselectQuery = new Query('Contacts')
            .withSelectFields(new Set<SObjectField>{ Contact.Id, Contact.Name });

        Test.startTest();
        try {
            database.query(subselectQuery);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'The expected exception was not thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void query_passQueryWithBindVariablesNull_queryWithoutBinds() {
        DatabaseService database = new DatabaseService();
        Query query = new Query(Account.SObjectType).withLimit(1);

        Test.startTest();
        List<SObject> results = database.query(query);
        Test.stopTest();

        Assert.isNotNull(results, 'Expected results to not be null');
    }

    @IsTest
    static void query_passQueryWithBindVariablesPopulated_queryWithBinds() {
        DatabaseService database = new DatabaseService();
        Query query = new Query(Account.SObjectType)
            .withWhereClause('Name != :accountName', new Map<String, Object>{ 'accountName' => 'Test' })
            .withLimit(1);

        Test.startTest();
        List<SObject> results = database.query(query);
        Test.stopTest();

        Assert.isNotNull(results, 'Expected results to not be null');
    }

    @IsTest
    static void getQueryLocator_passSubselectQuery_exceptionThrown() {
        DatabaseService database = new DatabaseService();
        Query subselectQuery = new Query('Contacts')
            .withSelectFields(new Set<SObjectField>{ Contact.Id, Contact.Name });

        Test.startTest();
        try {
            database.getQueryLocator(subselectQuery);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'The expected exception was not thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void getQueryLocator_passQueryWithBindVariablesNull_queryWithoutBinds() {
        DatabaseService database = new DatabaseService();
        Query query = new Query(Account.SObjectType).withLimit(1);

        Test.startTest();
        Database.QueryLocator queryLocator = database.getQueryLocator(query);
        Test.stopTest();

        Assert.isNotNull(queryLocator, 'Expected queryLocator to not be null');
    }

    @IsTest
    static void getQueryLocator_passQueryWithBindVariablesPopulated_queryWithBinds() {
        DatabaseService database = new DatabaseService();
        Query query = new Query(Account.SObjectType)
            .withWhereClause('Name != :accountName', new Map<String, Object>{ 'accountName' => 'Test' })
            .withLimit(1);

        Test.startTest();
        Database.QueryLocator queryLocator = database.getQueryLocator(query);
        Test.stopTest();

        Assert.isNotNull(queryLocator, 'Expected queryLocator to not be null');
    }

    @IsTest
    static void query_passAggregateQueryWithBindVariablesNull_queryWithoutBinds() {
        DatabaseService database = new DatabaseService();
        AggregateQuery query = new AggregateQuery(Account.SObjectType)
            .withSelectStatement('Name, COUNT(Id)')
            .withWhereClause('Name != \'Test\'')
            .withOtherStatements('GROUP BY Name');

        Test.startTest();
        List<AggregateResult> results = database.query(query);
        Test.stopTest();

        Assert.isNotNull(results, 'Expected results to not be null');
    }

    @IsTest
    static void query_passAggregateQueryWithBindVariablesPopulated_queryWithBinds() {
        DatabaseService database = new DatabaseService();
        AggregateQuery query = new AggregateQuery(Account.SObjectType)
            .withSelectStatement('Name, COUNT(Id)')
            .withWhereClause('Name != :accountName', new Map<String, Object>{ 'accountName' => 'Test' })
            .withOtherStatements('GROUP BY Name');

        Test.startTest();
        List<AggregateResult> results = database.query(query);
        Test.stopTest();

        Assert.isNotNull(results, 'Expected results to not be null');
    }

    @IsTest
    static void executeDml_insert_insertSuccessful() {
        Integer randomInt = Math.round(Math.random() * (99999 - 10000) + 10000);
        Account newAccount = new Account(Name = 'University of Copenhagen' + randomInt);

        DatabaseService database = new DatabaseService();
        Dml dml = new Dml(Dml.Operation.INSERT_RECORDS, newAccount);

        Test.startTest();
        List<Database.SaveResult> saveResult = (List<Database.SaveResult>) database.executeDml(dml);
        Test.stopTest();

        Assert.isTrue(saveResult.get(0).isSuccess(), 'Expected the DML to execute successfully');
        Assert.isNotNull(newAccount.Id, 'Expected the account to have been inserted');
    }

    @IsTest
    static void executeDml_update_updateSuccessful() {
        DatabaseService database = new DatabaseService();

        Account accountToUpdate = [SELECT Id FROM Account LIMIT 1];
        accountToUpdate.Name = 'Laser Interferometer Gravitational-Wave Observatory';

        Dml dml = new Dml(Dml.Operation.UPDATE_RECORDS, accountToUpdate);

        Test.startTest();
        List<Database.SaveResult> saveResult = (List<Database.SaveResult>) database.executeDml(dml);
        Test.stopTest();

        Assert.isTrue(saveResult.get(0).isSuccess(), 'Expected the DML to execute successfully');

        Account updatedAccount = [
            SELECT Name
            FROM Account
            WHERE Id = :accountToUpdate.Id
        ];

        Assert.areEqual(accountToUpdate.Name, updatedAccount.Name, 'Expected the account name to have changed');
    }

    @IsTest
    static void executeDml_upsertWithoutExternalId_upsertSuccessful() {
        Integer randomInt = Math.round(Math.random() * (99999 - 10000) + 10000);
        Account accountToInsert = new Account(Name = 'University of Copenhagen' + randomInt);
        Database.insert(accountToInsert);

        Account accountToUpdate = [SELECT Id FROM Account LIMIT 1];
        accountToUpdate.Name = 'Laser Interferometer Gravitational-Wave Observatory';

        DatabaseService database = new DatabaseService();
        Dml dml = new Dml(Dml.Operation.UPSERT_RECORDS, new List<Account>{ accountToInsert, accountToUpdate });

        Test.startTest();
        List<Database.UpsertResult> upsertResult = (List<Database.UpsertResult>) database.executeDml(dml);
        Test.stopTest();

        Assert.isTrue(upsertResult.get(0).isSuccess(), 'Expected the DML to execute successfully');
        Assert.isTrue(upsertResult.get(1).isSuccess(), 'Expected the DML to execute successfully');

        List<Account> upsertedAccounts = [
            SELECT Id, Name
            FROM Account
        ];

        Assert.areEqual(2, upsertedAccounts.size(), 'Expected two accounts to have been upserted');

        for (Account upsertedAccount : upsertedAccounts) {
            if (upsertedAccount.Id == accountToUpdate.Id) {
                Assert.areEqual(
                    accountToUpdate.Name,
                    upsertedAccount.Name,
                    'Expected the account name to have changed'
                );
            }
        }
    }

    @IsTest
    static void executeDml_delete_deleteSuccessful() {
        DatabaseService database = new DatabaseService();
        Account accountToDelete = [SELECT Id FROM Account LIMIT 1];

        Dml dml = new Dml(Dml.Operation.DELETE_RECORDS, accountToDelete);

        Test.startTest();
        List<Database.DeleteResult> deleteResult = (List<Database.DeleteResult>) database.executeDml(dml);
        Test.stopTest();

        Assert.isTrue(deleteResult.get(0).isSuccess(), 'Expected the DML to execute successfully');

        try {
            Account deletedAccount = [
                SELECT Id
                FROM Account
                WHERE Id = :accountToDelete.Id
            ];
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, QueryException.class, 'Expected a QueryException');

            Assert.areEqual(
                'List has no rows for assignment to SObject',
                e.getMessage(),
                'Expected the exception to be thrown because the account has been deleted'
            );
        }
    }

    @IsTest
    static void executeDml_undelete_undeleteSuccessful() {
        DatabaseService database = new DatabaseService();

        Account accountToUndelete = [SELECT Id FROM Account LIMIT 1];
        database.executeDml(new Dml(Dml.Operation.DELETE_RECORDS, accountToUndelete));

        Dml dml = new Dml(Dml.Operation.UNDELETE_RECORDS, accountToUndelete);

        Test.startTest();
        List<Database.UndeleteResult> undeleteResult = (List<Database.UndeleteResult>) database.executeDml(dml);
        Test.stopTest();

        Assert.isTrue(undeleteResult.get(0).isSuccess(), 'Expected the DML to execute successfully');

        Account undeletedAccount = [
            SELECT Id
            FROM Account
            WHERE Id = :accountToUndelete.Id
        ];

        Assert.isNotNull(undeletedAccount, 'Expected the account to have been undeleted');
    }
}