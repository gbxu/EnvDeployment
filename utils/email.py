# python3 email.py --sender sender@example.com --code xxx --recver receiver@example.com --msg "done"

import os
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr
import argparse

def send(sender, code, recver, title, msg, file):
    ret = True
    try:
        content = ''
        if file:
            with open(file, 'r', encoding='utf-8') as f:
                content = f.read()

        email = MIMEText(msg + '\ncontent: ======= \n\n' + content, 'plain', 'utf-8')
        email['From'] = formataddr(["Notifier", sender])
        email['To'] = formataddr(["EndUser", recver])
        email['Subject'] = title

        server = smtplib.SMTP_SSL("smtp.qq.com", 465)
        server.login(sender, code)
        server.sendmail(sender, [recver, ], email.as_string())
        server.quit()
    except Exception:
        ret = False

    if ret:
        print('successfully send out emails')
    else:
        print('fail to send out email')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='email')
    parser.add_argument('--sender', type=str, help='sender email')
    parser.add_argument('--code', type=str, help='sender password')
    parser.add_argument('--recver', type=str, help='recver email')
    parser.add_argument('--msg', type=str, default='an email notification', help='sending message')
    parser.add_argument('--file', type=str, default=None, help='include txt file content')
    parser.add_argument('--title', type=str, default='Notification', help='email title')
    args = parser.parse_args()

    if args.sender and args.code and args.recver:
        sender = args.sender
        code = args.code
        recver = args.recver
    else:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        file_path = os.path.join(current_dir, "../privatedata/email.txt")
        if os.path.exists(file_path):
            with open(file_path, 'r') as file:
                lines = [next(file).strip() for _ in range(3)]
                # 解析sender, code, recver
                data = {}
                for line in lines:
                    key, value = line.split(' ', 1)
                    data[key.lower()] = value
                sender = data.get('sender')
                code = data.get('code')
                recver = data.get('recver')
                print(f"Sender: {sender}, Code: {code}, Receiver: {recver}")
        else:
            print(f"File does not exist: {file_path}")

    send(sender, code, recver, args.title, args.msg, args.file)
