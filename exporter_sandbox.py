"""Export Module for ODBC"""
def main():
    """Main entry point"""

    import sys
    from os.path import join

    salesforce_type = str(sys.argv[1])
    client_type = str(sys.argv[2])
    client_emaillist = str(sys.argv[3])

    if len(sys.argv) < 4:
        print ("Calling error - missing inputs.  Expecting " +
               "salesforce_type client_type client_emaillist [Exporter_root]\n")
        return

    if len(sys.argv) == 5:
        Exporter_root = str(sys.argv[4])
    else:
        Exporter_root = "C:\\repo\\ODBC-Exporter-Private\\Clients\\" + sys.argv[2] + "\\ODBC-Exporter"

    sys.stdout = open(join(Exporter_root, '..\\Exporter.log'), 'w')
    print('ODBC Exporter Startup')

    exporter_directory = join(Exporter_root, "Clients\\" + client_type)
    print "Setting ODBC Exporter Directory: " + exporter_directory

    # Export Data
    print "\n\nODBC Exporter - Export Data Process\n\n"
    status_export = process_data(exporter_directory, salesforce_type, client_type, client_emaillist)

    print "ODBC Exporter process completed\n"

    if "Error" in status_export:
        sys.exit()

def process_data(exporter_directory, salesforce_type, client_type, client_emaillist):
    """Process Data based on data_mode"""

    from os import makedirs
    from os.path import exists
    from os.path import join

    sendto = client_emaillist.split(";")
    user = 'db.powerbi@501commons.org'
    smtpsrv = "smtp.office365.com"
    subject = "Export ODBC Data Results -"
    file_path = exporter_directory + "\\Status"
    if not exists(file_path):
        makedirs(file_path)
    export_path = exporter_directory + "\\Export"
    if not exists(export_path):
        makedirs(export_path)

    body = "Export Data\n\n"

    status_export = ""
    
    # Export data from Salesforce
    try:
        if not "Error" in subject:
            status_export = export_dataloader(exporter_directory,
                                              client_type, salesforce_type)
        else:
            status_export = "Error detected so skipped"
    except Exception as ex:
        subject += " Error Export"
        body += "\n\nUnexpected export error:" + str(ex)
    else:
        body += "\n\nExport\n" + status_export

        with open(join(exporter_directory, "..\\..\\..\\Exporter.log"), 'r') as logfile:
            body += logfile.read()

    if not "Error" in subject:
        subject += " Successful"

    # Send email results
    send_email(user, sendto, subject, body, file_path, smtpsrv)

    return status_export

def contains_data(file_name):
    """Check if file contains data after header"""

    line_index = 1
    with open(file_name) as file_open:
        for line in file_open:
            # Check if line empty
            line_check = line.replace(",", "")
            line_check = line_check.replace('"', '')
            if (line_index == 2 and line_check != "\n"):
                return True
            elif line_index > 2:
                return True

            line_index += 1

    return False

def export_dataloader(exporter_directory, client_type, salesforce_type):
    """Export out of ODBC using SQL Query files"""

    import csv
    import pyodbc
    import os
    from os import listdir
    from os import makedirs
    from os.path import exists
    from os.path import join

    query_path = exporter_directory + "\\Queries"
    csv_path = exporter_directory + "\\Export\\"
    if not exists(csv_path):
        makedirs(csv_path)

    return_status = ""

    with open(join(query_path, "..\\odbc_connect.dat"), 'r') as odbcconnectfile:
        odbc_connect=odbcconnectfile.read().replace('\n', '').rstrip()

    for file_name in listdir(query_path):
        if not ".sql" in file_name:
            continue

        export_name = os.path.splitext(file_name)[0]
        csv_name = join(csv_path, export_name + ".csv")

        message = "Starting Export Process: " + file_name
        print message

        # Read SQL Query
        with open(join(query_path, file_name), 'r') as sqlqueryfile:
            sqlquery=sqlqueryfile.read().replace('\n', ' ')

        # Query ODBC and write to CSV
        conn = pyodbc.connect(odbc_connect)
        crsr = conn.cursor()
        rows = crsr.execute(sqlquery)

        with open(csv_name, 'wb') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow([x[0] for x in crsr.description])  # column headers
            for row in rows:
                
                updated_row = list()
                for column in row:
                    if not column is None and isinstance(column, basestring):

                        # Check for newline in string
                        column = column.replace("\r", "")

                        # Check for double quote on names; name_last, name_first
                        column = column.replace(u"\u201c", "(").replace(u"\u201d", ")")

                    elif not column is None and isinstance(column, float):

                        # Convert float to integer
                        column = int(column)

                    updated_row.append(column)

                writer.writerow(updated_row)

        if "error" in return_status or not contains_data(csv_name):
            raise Exception("error export file empty: " + csv_name, (
                "ODBC Export Error: " + return_status))

    return return_status

def send_email(send_from, send_to, subject, text, file_path, server):
    """Send email via O365"""

    #https://stackoverflow.com/questions/3362600/how-to-send-email-attachments
    import base64
    import os
    import smtplib
    from os.path import basename
    from email.mime.application import MIMEApplication
    from email.mime.multipart import MIMEMultipart
    from email.mime.text import MIMEText
    from email.utils import COMMASPACE, formatdate

    print "Email subject: " + subject
    print "Email text: " + text
    
    msg = MIMEMultipart()

    msg['From'] = send_from
    msg['To'] = COMMASPACE.join(send_to)
    msg['Date'] = formatdate(localtime=True)
    msg['Subject'] = subject

    msg.attach(MIMEText(text))

    from os import listdir, remove
    from os.path import isfile, join
    onlyfiles = [join(file_path, f) for f in listdir(file_path)
                 if isfile(join(file_path, f))]

    for file_name in onlyfiles:
        if contains_data(file_name):
            with open(file_name, "rb") as file_name_open:
                part = MIMEApplication(
                    file_name_open.read(),
                    Name=basename(file_name)
                    )

            # After the file is closed
            part['Content-Disposition'] = 'attachment; filename="%s"' % basename(file_name)
            msg.attach(part)

    server = smtplib.SMTP(server, 587)
    server.starttls()
    server_password = os.environ['SERVER_EMAIL_PASSWORD']
    server.login(send_from, base64.b64decode(server_password))
    text = msg.as_string()
    server.sendmail(send_from, send_to, text)
    server.quit()

    # Delete all status files
    for file_name in onlyfiles:
        try:
            remove(file_name)
        except:
            continue

def send_salesforce():
    """Send results to Salesforce to handle notifications"""
    #Future update to send to salesforce to handle notifications instead of send_email
    #https://developer.salesforce.com/blogs/developer-relations/2014/01/python-and-the-force-com-rest-api-simple-simple-salesforce-example.html

if __name__ == "__main__":
    main()
