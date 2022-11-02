import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactDetails extends StatefulWidget {
  Contact contact;
  final Function(Contact) contactUpdate;
  final Function(Contact) contactDelete;
  ContactDetails(this.contact,
      {required this.contactUpdate, required this.contactDelete, super.key});

  @override
  State<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  List<String> actions = ['Edit', 'Delete'];

  @override
  Widget build(BuildContext context) {
    showDeleteConfirmation() {
      Widget cancelButton = TextButton(
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      Widget deleteButton = TextButton(
        child: const Text('Delete'),
        onPressed: () async {
          await ContactsService.deleteContact(widget.contact);
          widget.contactDelete(widget.contact);
          Navigator.of(context).pop();
        },
      );
      AlertDialog alert = AlertDialog(
        title: const Text('Delete contact?'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: <Widget>[cancelButton, deleteButton],
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          });
    }

    onAction(String action) async {
      switch (action) {
        case 'Edit':
          try {
            Contact updatedContact =
                await ContactsService.openExistingContact(widget.contact);
            setState(() {
              widget.contact = updatedContact;
            });
            widget.contactUpdate(widget.contact);
          } on FormOperationException catch (e) {
            switch (e.errorCode) {
              case null:
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());
            }
          }
          break;
        case 'Delete':
          showDeleteConfirmation();
          break;
      }
    }

    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.blueGrey[300]),
            child: Stack(alignment: Alignment.topCenter, children: [
              Center(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: (widget.contact.avatar != null &&
                            widget.contact.avatar!.isNotEmpty)
                        ? CircleAvatar(
                            backgroundImage:
                                MemoryImage(widget.contact.avatar as Uint8List),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.blueGrey[200],
                            child: const Icon(size: 50, Icons.person),
                          )),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      widget.contact.displayName ?? "",
                      style:
                          const TextStyle(fontSize: 24, color: Colors.black54),
                    )),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PopupMenuButton(
                    onSelected: onAction,
                    itemBuilder: (BuildContext context) {
                      return actions.map((String action) {
                        return PopupMenuItem(
                          value: action,
                          child: Text(action),
                        );
                      }).toList();
                    },
                  ),
                ),
              )
            ]),
          ),
          Expanded(
            child: ListView(shrinkWrap: true, children: <Widget>[
              ListTile(
                title: const Text("Name"),
                trailing: Text(
                  widget.contact.givenName ?? "",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                title: const Text("Family name"),
                trailing: Text(widget.contact.familyName ?? "",
                    style: const TextStyle(fontSize: 16)),
              ),
              Column(
                children: <Widget>[
                  const ListTile(title: Text("Phone")),
                  Column(
                    children: widget.contact.phones!
                        .map(
                          (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                              title: Text(i.value ?? ""),
                              trailing: (i.value != null && i.value!.isNotEmpty)
                                  ? Wrap(
                                      spacing: 6,
                                      children: [
                                        TextButton(
                                          child: const Icon(
                                            Icons.phone,
                                            color: Colors.teal,
                                          ),
                                          onPressed: () {
                                            try {
                                              launchUrlString(
                                                  'tel: ${i.value}');
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Some error occured'),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        TextButton(
                                          child: const Icon(
                                            Icons.message,
                                            color: Colors.teal,
                                          ),
                                          onPressed: () {
                                            try {
                                              launchUrlString(
                                                  'sms: ${i.value}');
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Some error occured'),
                                                ),
                                              );
                                            }
                                          },
                                        )
                                      ],
                                    )
                                  : const Text(''),
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
              Column(
                children: [
                  const ListTile(
                    title: Text("E-mail"),
                  ),
                  Column(
                    children: widget.contact.emails!
                        .map(
                          (e) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                              title: Text(e.value ?? ""),
                              trailing: (e.value != null && e.value!.isNotEmpty)
                                  ? TextButton(
                                      child: const Icon(
                                        Icons.email,
                                        color: Colors.teal,
                                      ),
                                      onPressed: () {
                                        try {
                                          launchUrlString('mailto: ${e.value}');
                                        } catch (ex) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Some error occured'),
                                            ),
                                          );
                                        }
                                      },
                                    )
                                  : const Text(''),
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  const ListTile(title: Text(" Address")),
                  Column(
                    children: widget.contact.postalAddresses!
                        .map(
                          (p) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                              title: Text(p.street ?? ""),
                              subtitle: Text(p.city ?? ""),
                              trailing: Text(p.postcode ?? ""),
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
            ]),
          ),
        ],
      )),
    );
  }
}
