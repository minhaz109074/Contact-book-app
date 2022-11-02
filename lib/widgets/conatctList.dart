import 'package:contacts/providers/authentication.dart';
import 'package:contacts/widgets/contactDetails.dart';
import 'package:contacts/widgets/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contacts/settings/theme.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts/widgets/center.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<Contact>? contacts;
  List<Contact>? filteredContacts;
  bool permissonDenied = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllContacts();
    searchController.addListener(() {
      getAllFilteredContacts();
    });
  }

  //get all the contacts from phone
  Future<void> getAllContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      List<Contact> _contacts = (await ContactsService.getContacts()).toList();
      setState(() {
        contacts = _contacts;
      });
    }
    setState(() {
      permissonDenied = !isGranted;
    });
  }

  String modifiedSearchTextForPhoneNumber(String phoneText) {
    return phoneText.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  //Search contacts by name and phone no.
  getAllFilteredContacts() {
    List<Contact> _filteredContacts = [];
    _filteredContacts.addAll(contacts!);
    if (searchController.text.isNotEmpty) {
      _filteredContacts.retainWhere((contact) {
        String serachedContact = searchController.text.toLowerCase();
        String modifiedSerachedContact =
            modifiedSearchTextForPhoneNumber(serachedContact);
        String contactName = contact.displayName?.toLowerCase() ?? "/";
        bool contactNameMatches = contactName.contains(serachedContact);
        if (contactNameMatches == true) {
          return true;
        }

        if (modifiedSerachedContact.isEmpty) {
          return false;
        }
        var phone = contact.phones!.firstWhereOrNull((phoneNumber) {
          String modifiedPhoneNumber =
              modifiedSearchTextForPhoneNumber(phoneNumber.value as String);
          return modifiedPhoneNumber.contains(modifiedSerachedContact);
        });

        return phone != null;
      });
      setState(() {
        filteredContacts = _filteredContacts;
      });
    } else {
      setState(() {
        contacts = contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Contacts",
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white70,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          )
        ],
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          height: double.infinity,
          child: (permissonDenied == true)
              ? const CenterText(
                  'Permission denied. Please restart the app and click allow to read your device contacts.')
              : (contacts == null)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : (contacts!.isNotEmpty)
                      ? Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 3),
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                    labelText: 'Search',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                    prefixIcon: const Icon(Icons.search)),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: (isSearching == true)
                                      ? filteredContacts!.length
                                      : contacts!.length,
                                  itemBuilder: ((context, index) {
                                    Contact contact = (isSearching == true)
                                        ? filteredContacts![index]
                                        : contacts![index];
                                    return (contact.displayName != null &&
                                            contact.phones != null &&
                                            contact.phones!.isNotEmpty)
                                        ? ListTile(
                                            title:
                                                Text(contact.displayName ?? ''),
                                            subtitle:
                                                (contact.phones!.length > 0)
                                                    ? Text(contact.phones!
                                                        .elementAt(0)
                                                        .value as String)
                                                    : const Text(''),
                                            leading: (contact.avatar != null &&
                                                    contact.avatar!.isNotEmpty)
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        MemoryImage(
                                                            contact.avatar
                                                                as Uint8List),
                                                  )
                                                : const CircleAvatar(
                                                    child: Icon(Icons.person),
                                                  ),
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(builder:
                                                      ((BuildContext context) {
                                                return ContactDetails(contact,
                                                    contactUpdate:
                                                        (Contact _contact) {
                                                  getAllContacts();
                                                }, contactDelete:
                                                        (Contact _contact) {
                                                  getAllContacts();
                                                  Navigator.of(context).pop();
                                                });
                                              })));
                                            },
                                          )
                                        : const Text('');
                                  })),
                            ),
                          ],
                        )
                      : const CenterText(
                          "Your phone has no contacts. Click the Plus button in the bottom right corner to add one.")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          try {
            Contact contact = await ContactsService.openContactForm();
            if (contact != null) {
              getAllContacts();
            }
          } on FormOperationException catch (e) {
            switch (e.errorCode) {
              case null:
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());
            }
          }
        },
      ),
    );
  }
}
