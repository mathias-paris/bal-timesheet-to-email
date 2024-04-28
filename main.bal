import ballerina/io;
import ballerina/log;
import ballerina/time;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import wso2/choreo.sendemail;

const emailSubject = "Your Monthly Timesheet";
configurable string email = ?;

configurable string dbhost = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbport = ?;

type TimeEntry record {|
    int id?;
    string user_id;
    time:Date date;
    string project;
    string worklog;
    int duration;
|};

postgresql:Client dbClient = check new (host = dbhost, username = dbUsername,
    password = dbPassword, database = dbName, port = dbport
);

// Create a new email client
sendemail:Client emailClient = check new ();

public function main() returns error? {
    log:printInfo("START");
    TimeEntry[] timeEntries = [];
    stream<TimeEntry, error?> resultStream = dbClient->query(
            `SELECT * FROM worklogs`
    );
    check from TimeEntry timeEntry in resultStream
        do {
            timeEntries.push(timeEntry);
        };
    check resultStream.close();
    // Send the email
    string _ = check emailClient->sendEmail(email, emailSubject, timeEntries.toString());
    io:println("Successfully sent the email.");
}
