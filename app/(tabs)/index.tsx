import { MaterialIcons } from "@expo/vector-icons";
import { useMemo, useState } from "react";
import {
  Linking,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";
import { StatusBar } from "expo-status-bar";

import { ScreenContainer } from "@/components/screen-container";

const UBER_EATS_URL = "https://www.ubereats.com/";
const UBER_RIDES_URL = "https://m.uber.com/ul/";

type Section = "Food" | "Rides";

type FoodPlace = {
  name: string;
  cuisine: string;
  note: string;
  icon: "restaurant" | "local-pizza" | "lunch-dining" | "local-cafe";
};

const FOOD_PLACES: FoodPlace[] = [
  { name: "Pret A Manger", cuisine: "Sandwiches · Coffee", note: "Popular near you", icon: "local-cafe" },
  { name: "PizzaExpress", cuisine: "Pizza · Italian", note: "Comfort food favourites", icon: "local-pizza" },
  { name: "Five Guys", cuisine: "Burgers · American", note: "Made to order", icon: "lunch-dining" },
  { name: "Wagamama", cuisine: "Japanese · Noodles", note: "Fresh bowls and sides", icon: "restaurant" },
];

const RIDE_OPTIONS = [
  { name: "UberX", detail: "Affordable everyday rides", icon: "directions-car" as const },
  { name: "Uber Comfort", detail: "Extra legroom and comfort", icon: "airline-seat-recline-normal" as const },
  { name: "UberXL", detail: "Room for more passengers", icon: "airport-shuttle" as const },
];

function openUber(url: string) {
  void Linking.openURL(url);
}

export default function HomeScreen() {
  const [section, setSection] = useState<Section>("Food");
  const [query, setQuery] = useState("");

  const foodResults = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    if (!normalized) return FOOD_PLACES;
    return FOOD_PLACES.filter((place) =>
      `${place.name} ${place.cuisine}`.toLowerCase().includes(normalized),
    );
  }, [query]);

  return (
    <ScreenContainer edges={["top", "left", "right"]}>
      <StatusBar style="dark" />
      <ScrollView
        contentContainerStyle={styles.content}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.topBar}>
          <Pressable accessibilityRole="button" style={styles.topIcon}>
            <MaterialIcons name="person-outline" size={20} color="#171717" />
          </Pressable>
          <Text style={styles.wordmark}>Uberide</Text>
          <Pressable accessibilityRole="button" style={styles.topIcon}>
            <MaterialIcons name="menu" size={21} color="#171717" />
          </Pressable>
        </View>

        <View style={styles.segmentBar}>
          {(["Food", "Rides"] as Section[]).map((item) => (
            <Pressable
              accessibilityRole="tab"
              accessibilityState={{ selected: section === item }}
              key={item}
              onPress={() => {
                setSection(item);
                setQuery("");
              }}
              style={({ pressed }) => [
                styles.segment,
                section === item && styles.segmentSelected,
                pressed && styles.pressed,
              ]}
            >
              <MaterialIcons
                name={item === "Food" ? "restaurant" : "directions-car"}
                size={15}
                color={section === item ? "#FFFFFF" : "#555555"}
              />
              <Text style={[styles.segmentText, section === item && styles.segmentTextSelected]}>{item}</Text>
            </Pressable>
          ))}
        </View>

        <View style={styles.headingRow}>
          <View style={styles.headingCopy}>
            <Text style={styles.heading}>{section === "Food" ? "Order food" : "Request a ride"}</Text>
            <Text style={styles.subheading}>
              {section === "Food" ? "Real restaurants, then checkout on Uber Eats." : "Choose an Uber-style ride, then continue on Uber."}
            </Text>
          </View>
          <View style={styles.locationPill}>
            <MaterialIcons name="location-on" size={13} color="#222222" />
            <Text style={styles.locationText}>Nearby</Text>
          </View>
        </View>

        <View style={styles.searchBox}>
          <MaterialIcons name="search" size={19} color="#5F5F5F" />
          <TextInput
            accessibilityLabel={section === "Food" ? "Search food places" : "Search ride options"}
            autoCapitalize="words"
            onChangeText={setQuery}
            placeholder={section === "Food" ? "Search restaurants or cuisine" : "Search ride type"}
            placeholderTextColor="#8A8A8A"
            returnKeyType="search"
            style={styles.searchInput}
            value={query}
          />
          {query.length > 0 ? (
            <Pressable accessibilityRole="button" accessibilityLabel="Clear search" onPress={() => setQuery("")}>
              <MaterialIcons name="cancel" size={17} color="#8A8A8A" />
            </Pressable>
          ) : null}
        </View>

        {section === "Food" ? (
          <View style={styles.listCard}>
            {foodResults.map((place, index) => (
              <View key={place.name} style={[styles.foodRow, index < foodResults.length - 1 && styles.rowDivider]}>
                <View style={styles.foodIcon}>
                  <MaterialIcons name={place.icon} size={20} color="#111111" />
                </View>
                <View style={styles.rowCopy}>
                  <Text style={styles.rowTitle}>{place.name}</Text>
                  <Text style={styles.rowDetail}>{place.cuisine}</Text>
                  <Text style={styles.rowNote}>{place.note}</Text>
                </View>
                <Pressable
                  accessibilityRole="button"
                  accessibilityLabel={`Buy from ${place.name}`}
                  onPress={() => openUber(UBER_EATS_URL)}
                  style={({ pressed }) => [styles.buyButton, pressed && styles.buyPressed]}
                >
                  <Text style={styles.buyText}>BUY</Text>
                </Pressable>
              </View>
            ))}
            {foodResults.length === 0 ? (
              <View style={styles.emptyState}>
                <Text style={styles.emptyTitle}>No places found</Text>
                <Text style={styles.emptyCopy}>Try a restaurant name or cuisine.</Text>
              </View>
            ) : null}
          </View>
        ) : (
          <View style={styles.rideList}>
            {RIDE_OPTIONS.filter((ride) => ride.name.toLowerCase().includes(query.trim().toLowerCase())).map((ride) => (
              <View key={ride.name} style={styles.rideCard}>
                <View style={styles.rideIcon}>
                  <MaterialIcons name={ride.icon} size={22} color="#FFFFFF" />
                </View>
                <View style={styles.rowCopy}>
                  <Text style={styles.rowTitle}>{ride.name}</Text>
                  <Text style={styles.rowDetail}>{ride.detail}</Text>
                  <Text style={styles.rowNote}>Continue securely on Uber</Text>
                </View>
                <Pressable
                  accessibilityRole="button"
                  accessibilityLabel={`Request ${ride.name}`}
                  onPress={() => openUber(UBER_RIDES_URL)}
                  style={({ pressed }) => [styles.requestButton, pressed && styles.buyPressed]}
                >
                  <Text style={styles.requestText}>GO</Text>
                </Pressable>
              </View>
            ))}
          </View>
        )}

        <Pressable
          accessibilityRole="button"
          onPress={() => openUber(section === "Food" ? UBER_EATS_URL : UBER_RIDES_URL)}
          style={({ pressed }) => [styles.footerButton, pressed && styles.buyPressed]}
        >
          <Text style={styles.footerButtonText}>{section === "Food" ? "Open Uber Eats" : "Open Uber"}</Text>
          <MaterialIcons name="open-in-new" size={16} color="#FFFFFF" />
        </Pressable>

        <Text style={styles.disclaimer}>
          Uberide is an independent shortcut interface. Checkout, payment, accounts, and ride requests happen on Uber&apos;s official website.
        </Text>
      </ScrollView>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  content: {
    paddingHorizontal: 12,
    paddingTop: Platform.OS === "web" ? 12 : 5,
    paddingBottom: 28,
    maxWidth: 430,
    width: "100%",
    alignSelf: "center",
    backgroundColor: "#FFFFFF",
  },
  topBar: {
    height: 42,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    borderBottomWidth: 1,
    borderBottomColor: "#D2D2D2",
  },
  topIcon: {
    width: 35,
    height: 35,
    alignItems: "center",
    justifyContent: "center",
  },
  wordmark: {
    color: "#111111",
    fontSize: 20,
    fontWeight: "400",
    letterSpacing: 2.2,
  },
  segmentBar: {
    flexDirection: "row",
    marginTop: 13,
    borderWidth: 1,
    borderColor: "#1B1B1B",
    borderRadius: 4,
    overflow: "hidden",
  },
  segment: {
    flex: 1,
    minHeight: 37,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
    backgroundColor: "#FFFFFF",
  },
  segmentSelected: {
    backgroundColor: "#171717",
  },
  segmentText: {
    color: "#444444",
    fontSize: 13,
    fontWeight: "700",
  },
  segmentTextSelected: {
    color: "#FFFFFF",
  },
  headingRow: {
    flexDirection: "row",
    alignItems: "flex-start",
    justifyContent: "space-between",
    marginTop: 22,
    marginBottom: 12,
  },
  headingCopy: {
    flex: 1,
    paddingRight: 10,
  },
  heading: {
    color: "#111111",
    fontSize: 23,
    lineHeight: 27,
    fontWeight: "700",
  },
  subheading: {
    color: "#676767",
    fontSize: 12,
    lineHeight: 17,
    marginTop: 5,
  },
  locationPill: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 7,
    paddingVertical: 5,
    borderWidth: 1,
    borderColor: "#C5C5C5",
    borderRadius: 3,
  },
  locationText: {
    color: "#333333",
    fontSize: 10,
    marginLeft: 2,
  },
  searchBox: {
    minHeight: 43,
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 10,
    borderWidth: 1,
    borderColor: "#BEBEBE",
    borderRadius: 3,
    backgroundColor: "#FFFFFF",
  },
  searchInput: {
    flex: 1,
    minHeight: 41,
    color: "#111111",
    fontSize: 13,
    paddingHorizontal: 8,
  },
  listCard: {
    marginTop: 14,
    borderWidth: 1,
    borderColor: "#CFCFCF",
    borderRadius: 4,
    backgroundColor: "#FFFFFF",
  },
  foodRow: {
    minHeight: 83,
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 9,
    paddingVertical: 9,
  },
  rowDivider: {
    borderBottomWidth: 1,
    borderBottomColor: "#DDDDDD",
  },
  foodIcon: {
    width: 42,
    height: 42,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "#D2D2D2",
    borderRadius: 3,
    backgroundColor: "#F5F5F5",
    marginRight: 9,
  },
  rowCopy: {
    flex: 1,
    minWidth: 0,
  },
  rowTitle: {
    color: "#111111",
    fontSize: 14,
    fontWeight: "700",
  },
  rowDetail: {
    color: "#454545",
    fontSize: 11,
    marginTop: 3,
  },
  rowNote: {
    color: "#858585",
    fontSize: 10,
    marginTop: 3,
  },
  buyButton: {
    minWidth: 47,
    minHeight: 34,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 3,
    backgroundColor: "#171717",
    marginLeft: 7,
  },
  buyText: {
    color: "#FFFFFF",
    fontSize: 11,
    fontWeight: "700",
    letterSpacing: 0.5,
  },
  buyPressed: {
    opacity: 0.65,
  },
  emptyState: {
    padding: 22,
    alignItems: "center",
  },
  emptyTitle: {
    color: "#111111",
    fontSize: 14,
    fontWeight: "700",
  },
  emptyCopy: {
    color: "#777777",
    fontSize: 11,
    marginTop: 4,
  },
  rideList: {
    marginTop: 14,
    gap: 9,
  },
  rideCard: {
    minHeight: 78,
    flexDirection: "row",
    alignItems: "center",
    padding: 10,
    borderWidth: 1,
    borderColor: "#CFCFCF",
    borderRadius: 4,
    backgroundColor: "#FFFFFF",
  },
  rideIcon: {
    width: 43,
    height: 43,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 3,
    backgroundColor: "#171717",
    marginRight: 10,
  },
  requestButton: {
    minWidth: 44,
    minHeight: 34,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 3,
    backgroundColor: "#171717",
    marginLeft: 7,
  },
  requestText: {
    color: "#FFFFFF",
    fontSize: 11,
    fontWeight: "700",
  },
  footerButton: {
    minHeight: 43,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 7,
    marginTop: 17,
    borderRadius: 3,
    backgroundColor: "#171717",
  },
  footerButtonText: {
    color: "#FFFFFF",
    fontSize: 13,
    fontWeight: "700",
  },
  disclaimer: {
    color: "#878787",
    fontSize: 9,
    lineHeight: 13,
    textAlign: "center",
    marginTop: 15,
    paddingHorizontal: 8,
  },
  pressed: {
    opacity: 0.7,
  },
});
