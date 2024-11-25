import 'dart:async';
import 'dart:convert';
import 'package:country_search/country_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CountrySearch extends StatefulWidget {
  const CountrySearch({super.key});

  @override
  State<CountrySearch> createState() => _CountrySearchState();
}

final searchController = TextEditingController();

class _CountrySearchState extends State<CountrySearch> {
  List<Country> countryList = [];
  Country? selectedCountry;
  bool loading = false;
  Timer? deBouncer;
  String message = '';

  void onSearchChanged(String searchQuery) {
    if ((deBouncer?.isActive) ?? false) deBouncer?.cancel();

    if (searchQuery.isEmpty) {
      setState(() {
        countryList.clear();
      });
      return;
    }

    deBouncer = Timer(const Duration(milliseconds: 1500), () {
      getSearchResult(query: searchQuery);
    });
  }

  Future<void> getSearchResult({String? query}) async {
    try{
      setState(() {
        loading = true;
        message = '';
      });

      final response = await http.get(Uri.parse("https://restcountries.com/v3.1/name/$query"));

      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        final decodedList = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          countryList = decodedList.map((country) => Country.fromJson(country)).toList();
        });
      } else if (response.statusCode == 404) {
        message = jsonDecode(response.body)['message'];
      }
    }catch(e,st){
      debugPrint("exceptional error $e $st");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SafeArea(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    suffixIcon: loading
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                        : !loading && searchController.text.isNotEmpty
                        ? InkWell(
                      onTap: () {
                        setState(() {
                          searchController.clear();
                        });
                      },
                      child: const Icon(Icons.clear),
                    )
                        : const SizedBox(),
                    hintText: 'Type something...',
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                ),
              ),
              if (countryList.isNotEmpty)
                Container(
                  height: size.height * 0.2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView.builder(
                    itemCount: countryList.length,
                    itemBuilder: (context, index) {
                      final country = countryList[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedCountry = country;
                            countryList.clear();
                            FocusManager.instance.primaryFocus?.unfocus();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              const SizedBox(
                                height: 10,
                                width: 10,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: Text("${country.commonName} | ${country.region} |",)),
                              SizedBox(
                                height: size.height * 0.02,
                                child: Image.network(country.flagUrl ?? ''),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (message.isNotEmpty) Text(message),
              if (selectedCountry != null)
                SizedBox(
                  height: size.height, // Ensure enough height for centering
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                    children: [
                      Container(
                        width: double.infinity,
                        height: size.height * 0.5,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.blue.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.blueAccent, width: 2),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(selectedCountry?.flagUrl ?? ''),
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              selectedCountry?.commonName ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  selectedCountry?.region ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people, color: Colors.blueAccent, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  "Population: ${selectedCountry?.population?.toString() ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}
