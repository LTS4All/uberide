import { MaterialIcons } from "@expo/vector-icons";
import { useMemo, useState } from "react";
import {
  Alert,
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
import {
  filterSearchChoices,
  OPENFREEMAP_HOME,
  OPENFREEMAP_STYLE,
  UBER_DEVELOPERS,
} from "@/lib/uberide-config";

function MapPreview({ onOpenMap }: { onOpenMap: () => void }) {
  return (
    <View style={styles.mapCard}>
      <View style={styles.mapHeader}>
        <View>
          <Text style={styles.eyebrow}>LIVE MAP</Text>
          <Text style={styles.mapTitle}>OpenFreeMap</Text>
        </View>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="Open the full OpenFreeMap map"
          onPress={onOpenMap}
          style={({ pressed }) => [styles.mapLink, pressed && styles.pressed]}
        >
          <Text style={styles.mapLinkText}>Open full map</Text>
          <MaterialIcons name="north-east" size={16} color="#17312C" />
        </Pressable>
      </View>
      <View style={styles.mapCanvas}>
        <View style={[styles.mapRoad, styles.roadOne]} />
        <View style={[styles.mapRoad, styles.roadTwo]} />
        <View style={[styles.mapRoad, styles.roadThree]} />
        <View style={[styles.mapWater, styles.waterOne]} />
        <View style={[styles.mapWater, styles.waterTwo]} />
        <View style={[styles.mapBlock, styles.blockOne]} />
        <View style={[styles.mapBlock, styles.blockTwo]} />
        <View style={[styles.mapBlock, styles.blockThree]} />
        <View style={[styles.mapBlock, styles.blockFour]} />
        <View style={styles.mapPin}>
          <MaterialIcons name="local-taxi" size={17} color="#F7F5EF" />
        </View>
        <View style={styles.mapLabel}>
          <Text style={styles.mapLabelText}>Driver location appears here after authorization</Text>
        </View>
      </View>
      <Text style={styles.mapAttribution}>
        Style: Liberty · © OpenMapTiles · © OpenStreetMap contributors
      </Text>
      <Text style={styles.mapUrl}>{OPENFREEMAP_STYLE}</Text>
    </View>
  );
}

export default function HomeScreen() {
  const [query, setQuery] = useState("");
  const [selectedPlace, setSelectedPlace] = useState<string | null>(null);
  const [rideState, setRideState] = useState<"idle" | "connecting">("idle");
  const [certsAcknowledged, setCertsAcknowledged] = useState(false);

  const visibleChoices = useMemo(() => {
    return filterSearchChoices(query);
  }, [query]);

  const openMap = () => {
    void Linking.openURL(OPENFREEMAP_HOME);
  };

  const connectUber = () => {
    setRideState("connecting");
    Alert.alert(
      "Connect an authorized Uber ride",
      "Uberide can show driver location only for an active ride or an authorized fleet account. The production build must complete Uber OAuth on a secure server; it must never put a client secret in the app.",
      [
        { text: "Cancel", style: "cancel", onPress: () => setRideState("idle") },
        {
          text: "Uber developer docs",
          onPress: () => {
            setRideState("idle");
            void Linking.openURL(UBER_DEVELOPERS);
          },
        },
      ],
    );
  };

  const showCertificateGuidance = () => {
    Alert.alert(
      "No unknown certificates needed",
      "Uberide does not install certificates. OpenFreeMap and Uber use HTTPS. Only install a profile or certificate supplied by your employer or device administrator, and verify its source first. On iOS 9.3.5, check Settings > General > Profile only when instructed by a trusted administrator.",
      [
        { text: "Not now", style: "cancel" },
        {
          text: "I understand",
          onPress: () => setCertsAcknowledged(true),
        },
      ],
    );
  };

  return (
    <ScreenContainer edges={["top", "left", "right"]}>
      <StatusBar style="dark" />
      <ScrollView
        contentContainerStyle={styles.content}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.brandRow}>
          <View style={styles.logoMark}>
            <View style={styles.logoLine} />
            <View style={styles.logoDot} />
          </View>
          <View>
            <Text style={styles.logoText}>Uberide</Text>
            <Text style={styles.logoSubtext}>ride clarity, without the clutter</Text>
          </View>
          <View style={styles.legacyBadge}>
            <Text style={styles.legacyBadgeText}>iOS 9</Text>
          </View>
        </View>

        <View style={styles.heroBlock}>
          <Text style={styles.greeting}>Where are you headed?</Text>
          <Text style={styles.heroCopy}>
            Search a pickup or destination, then connect an authorized active ride.
          </Text>
        </View>

        <View style={styles.searchShell}>
          <MaterialIcons name="search" size={21} color="#65736D" />
          <TextInput
            accessibilityLabel="Search pickup or destination"
            autoCapitalize="words"
            clearButtonMode="while-editing"
            onChangeText={(value) => {
              setQuery(value);
              setSelectedPlace(null);
            }}
            onSubmitEditing={() => {
              if (visibleChoices[0]) setSelectedPlace(visibleChoices[0].label);
            }}
            placeholder="Search pickup or destination"
            placeholderTextColor="#88928D"
            returnKeyType="search"
            style={styles.searchInput}
            value={query}
          />
          <View style={styles.searchKey}>
            <Text style={styles.searchKeyText}>⌘K</Text>
          </View>
        </View>

        <View style={styles.choiceArea}>
          {visibleChoices.map((choice) => (
            <Pressable
              accessibilityRole="button"
              accessibilityLabel={`Choose ${choice.label}`}
              key={choice.label}
              onPress={() => {
                setSelectedPlace(choice.label);
                setQuery(choice.label);
              }}
              style={({ pressed }) => [styles.choiceRow, pressed && styles.pressed]}
            >
              <View style={styles.choiceIcon}>
                <MaterialIcons
                  name={choice.label === "Current location" ? "my-location" : "place"}
                  size={17}
                  color="#17312C"
                />
              </View>
              <View style={styles.choiceCopy}>
                <Text style={styles.choiceLabel}>{choice.label}</Text>
                <Text style={styles.choiceDetail}>{choice.detail}</Text>
              </View>
              <MaterialIcons name="chevron-right" size={19} color="#99A29D" />
            </Pressable>
          ))}
          {visibleChoices.length === 0 ? (
            <View style={styles.emptySearch}>
              <Text style={styles.emptySearchTitle}>No saved places found</Text>
              <Text style={styles.emptySearchCopy}>
                Press search to keep this as a pickup request in the production build.
              </Text>
            </View>
          ) : null}
        </View>

        {selectedPlace ? (
          <View style={styles.selectionBanner}>
            <MaterialIcons name="check-circle" size={18} color="#1E7A55" />
            <Text style={styles.selectionText}>Pickup set to {selectedPlace}</Text>
            <Pressable
              accessibilityRole="button"
              onPress={() => setSelectedPlace(null)}
              style={({ pressed }) => [styles.clearButton, pressed && styles.pressed]}
            >
              <Text style={styles.clearButtonText}>Clear</Text>
            </Pressable>
          </View>
        ) : null}

        <MapPreview onOpenMap={openMap} />

        <View style={styles.rideCard}>
          <View style={styles.cardTopRow}>
            <View style={styles.cardIcon}>
              <MaterialIcons name="near-me" size={20} color="#F7F5EF" />
            </View>
            <View style={styles.cardTitleCopy}>
              <Text style={styles.cardKicker}>AUTHORIZED RIDE STATUS</Text>
              <Text style={styles.cardTitle}>
                {rideState === "connecting" ? "Waiting for authorization" : "No active ride connected"}
              </Text>
            </View>
            <View style={styles.statusDot} />
          </View>
          <Text style={styles.cardBody}>
            Driver location is shown only when Uber grants access for your active ride or fleet account. Location data is not guessed, scraped, or shared with third parties.
          </Text>
          <Pressable
            accessibilityRole="button"
            onPress={connectUber}
            style={({ pressed }) => [styles.primaryButton, pressed && styles.primaryPressed]}
          >
            <Text style={styles.primaryButtonText}>Connect authorized Uber ride</Text>
            <MaterialIcons name="arrow-forward" size={19} color="#17312C" />
          </Pressable>
        </View>

        <View style={styles.certCard}>
          <View style={styles.certIcon}>
            <MaterialIcons name={certsAcknowledged ? "verified-user" : "lock-outline"} size={21} color="#17312C" />
          </View>
          <View style={styles.certCopy}>
            <Text style={styles.certTitle}>{certsAcknowledged ? "Certificate check acknowledged" : "Do you want to install certificates?"}</Text>
            <Text style={styles.certBody}>
              {certsAcknowledged
                ? "No unknown profile will be installed by Uberide."
                : "No third-party certificate is needed for the public APIs."}
            </Text>
          </View>
          <Pressable
            accessibilityRole="button"
            onPress={showCertificateGuidance}
            style={({ pressed }) => [styles.secondaryButton, pressed && styles.pressed]}
          >
            <Text style={styles.secondaryButtonText}>{certsAcknowledged ? "View" : "Yes"}</Text>
          </Pressable>
          <Pressable
            accessibilityRole="button"
            onPress={() => setCertsAcknowledged(true)}
            style={({ pressed }) => [styles.secondaryButton, styles.alreadyButton, pressed && styles.pressed]}
          >
            <Text style={styles.secondaryButtonText}>Already done</Text>
          </Pressable>
        </View>

        <View style={styles.footer}>
          <Text style={styles.footerText}>Uberide is an independent prototype and is not affiliated with Uber.</Text>
          <Text style={styles.footerText}>Built for a legacy iOS 9.3.5 Objective-C implementation.</Text>
        </View>
      </ScrollView>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  content: {
    paddingHorizontal: 20,
    paddingTop: Platform.OS === "web" ? 22 : 14,
    paddingBottom: 36,
    maxWidth: 680,
    width: "100%",
    alignSelf: "center",
  },
  brandRow: {
    flexDirection: "row",
    alignItems: "center",
    minHeight: 46,
  },
  logoMark: {
    width: 36,
    height: 36,
    borderRadius: 12,
    backgroundColor: "#17312C",
    marginRight: 10,
    position: "relative",
    overflow: "hidden",
  },
  logoLine: {
    position: "absolute",
    left: 8,
    top: 17,
    width: 24,
    height: 2,
    backgroundColor: "#B4E36C",
    transform: [{ rotate: "-42deg" }],
  },
  logoDot: {
    position: "absolute",
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: "#F7F5EF",
    right: 7,
    top: 7,
  },
  logoText: {
    color: "#17312C",
    fontSize: 19,
    fontWeight: "800",
    letterSpacing: -0.4,
  },
  logoSubtext: {
    color: "#74817B",
    fontSize: 10,
    marginTop: 2,
    letterSpacing: 0.2,
  },
  legacyBadge: {
    marginLeft: "auto",
    paddingHorizontal: 9,
    paddingVertical: 5,
    borderRadius: 99,
    backgroundColor: "#E7F2D8",
  },
  legacyBadgeText: {
    color: "#315A36",
    fontSize: 10,
    fontWeight: "800",
    letterSpacing: 0.5,
  },
  heroBlock: {
    marginTop: 42,
    marginBottom: 18,
  },
  greeting: {
    color: "#17312C",
    fontSize: 34,
    lineHeight: 40,
    fontWeight: "800",
    letterSpacing: -1.3,
  },
  heroCopy: {
    color: "#687871",
    fontSize: 14,
    lineHeight: 21,
    marginTop: 9,
    maxWidth: 440,
  },
  searchShell: {
    flexDirection: "row",
    alignItems: "center",
    minHeight: 54,
    borderWidth: 1,
    borderColor: "#D7DFD7",
    borderRadius: 17,
    backgroundColor: "#FFFFFF",
    paddingHorizontal: 15,
    shadowColor: "#17312C",
    shadowOpacity: 0.05,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 12,
    elevation: 2,
  },
  searchInput: {
    flex: 1,
    color: "#17312C",
    fontSize: 15,
    paddingHorizontal: 10,
    minHeight: 52,
  },
  searchKey: {
    paddingHorizontal: 8,
    paddingVertical: 5,
    borderRadius: 6,
    backgroundColor: "#F0F3EE",
  },
  searchKeyText: {
    color: "#84918A",
    fontSize: 11,
    fontWeight: "700",
  },
  choiceArea: {
    marginTop: 10,
    backgroundColor: "#FFFFFF",
    borderRadius: 17,
    overflow: "hidden",
    borderWidth: 1,
    borderColor: "#E6EBE5",
  },
  choiceRow: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 13,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: "#EFF2EE",
  },
  choiceIcon: {
    width: 32,
    height: 32,
    borderRadius: 11,
    backgroundColor: "#E7F2D8",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 11,
  },
  choiceCopy: {
    flex: 1,
  },
  choiceLabel: {
    color: "#17312C",
    fontSize: 14,
    fontWeight: "700",
  },
  choiceDetail: {
    color: "#81908A",
    fontSize: 11,
    marginTop: 3,
  },
  emptySearch: {
    padding: 17,
  },
  emptySearchTitle: {
    color: "#17312C",
    fontSize: 14,
    fontWeight: "700",
  },
  emptySearchCopy: {
    color: "#81908A",
    fontSize: 12,
    lineHeight: 18,
    marginTop: 5,
  },
  selectionBanner: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 12,
    backgroundColor: "#EEF8E8",
  },
  selectionText: {
    flex: 1,
    color: "#2E5941",
    fontSize: 12,
    fontWeight: "700",
    marginLeft: 7,
  },
  clearButton: {
    padding: 4,
  },
  clearButtonText: {
    color: "#2E5941",
    fontSize: 12,
    fontWeight: "800",
  },
  mapCard: {
    marginTop: 20,
    overflow: "hidden",
    borderRadius: 22,
    backgroundColor: "#F1F4EA",
    borderWidth: 1,
    borderColor: "#DDE5D7",
  },
  mapHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 16,
    paddingTop: 15,
    paddingBottom: 12,
  },
  eyebrow: {
    color: "#7B8B81",
    fontSize: 10,
    fontWeight: "800",
    letterSpacing: 1.3,
  },
  mapTitle: {
    color: "#17312C",
    fontSize: 18,
    fontWeight: "800",
    marginTop: 3,
  },
  mapLink: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 5,
    paddingLeft: 8,
  },
  mapLinkText: {
    color: "#17312C",
    fontSize: 11,
    fontWeight: "800",
    marginRight: 4,
  },
  mapCanvas: {
    height: 222,
    position: "relative",
    overflow: "hidden",
    backgroundColor: "#DCEBD0",
  },
  mapRoad: {
    position: "absolute",
    backgroundColor: "#FCFAF0",
    borderWidth: 1,
    borderColor: "#D4DACB",
  },
  roadOne: {
    width: 460,
    height: 22,
    left: -25,
    top: 80,
    transform: [{ rotate: "-20deg" }],
  },
  roadTwo: {
    width: 390,
    height: 18,
    left: 70,
    top: 165,
    transform: [{ rotate: "18deg" }],
  },
  roadThree: {
    width: 20,
    height: 340,
    left: 220,
    top: -42,
    transform: [{ rotate: "28deg" }],
  },
  mapWater: {
    position: "absolute",
    backgroundColor: "#B8DCE1",
    opacity: 0.9,
  },
  waterOne: {
    width: 250,
    height: 74,
    left: -36,
    bottom: -25,
    transform: [{ rotate: "-12deg" }],
  },
  waterTwo: {
    width: 190,
    height: 46,
    right: -38,
    top: -12,
    transform: [{ rotate: "34deg" }],
  },
  mapBlock: {
    position: "absolute",
    backgroundColor: "#C7DCB9",
    borderRadius: 7,
    opacity: 0.7,
  },
  blockOne: { width: 72, height: 42, left: 22, top: 19 },
  blockTwo: { width: 82, height: 50, right: 25, top: 68 },
  blockThree: { width: 58, height: 33, left: 124, bottom: 24 },
  blockFour: { width: 90, height: 36, right: 62, bottom: 16 },
  mapPin: {
    position: "absolute",
    left: "50%",
    top: "48%",
    width: 38,
    height: 38,
    marginLeft: -19,
    marginTop: -19,
    borderRadius: 19,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#17312C",
    borderWidth: 4,
    borderColor: "rgba(255,255,255,0.7)",
    shadowColor: "#17312C",
    shadowOpacity: 0.22,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 7,
    elevation: 4,
  },
  mapLabel: {
    position: "absolute",
    left: 16,
    right: 16,
    bottom: 13,
    paddingHorizontal: 11,
    paddingVertical: 8,
    borderRadius: 9,
    backgroundColor: "rgba(255,255,255,0.9)",
  },
  mapLabelText: {
    color: "#4E625A",
    fontSize: 11,
    textAlign: "center",
  },
  mapAttribution: {
    color: "#718077",
    fontSize: 9,
    paddingHorizontal: 15,
    paddingTop: 8,
  },
  mapUrl: {
    color: "#9AA69E",
    fontSize: 9,
    paddingHorizontal: 15,
    paddingBottom: 12,
    paddingTop: 2,
  },
  rideCard: {
    marginTop: 16,
    padding: 17,
    borderRadius: 20,
    backgroundColor: "#17312C",
  },
  cardTopRow: {
    flexDirection: "row",
    alignItems: "center",
  },
  cardIcon: {
    width: 38,
    height: 38,
    borderRadius: 12,
    backgroundColor: "#315A36",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 11,
  },
  cardTitleCopy: {
    flex: 1,
  },
  cardKicker: {
    color: "#B4E36C",
    fontSize: 9,
    fontWeight: "800",
    letterSpacing: 1.1,
  },
  cardTitle: {
    color: "#F7F5EF",
    fontSize: 16,
    fontWeight: "800",
    marginTop: 4,
  },
  statusDot: {
    width: 9,
    height: 9,
    borderRadius: 5,
    backgroundColor: "#D8E3D8",
  },
  cardBody: {
    color: "#C5D1C7",
    fontSize: 12,
    lineHeight: 18,
    marginTop: 14,
  },
  primaryButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    minHeight: 46,
    borderRadius: 13,
    backgroundColor: "#B4E36C",
    marginTop: 16,
  },
  primaryButtonText: {
    color: "#17312C",
    fontSize: 13,
    fontWeight: "800",
    marginRight: 7,
  },
  primaryPressed: {
    opacity: 0.86,
    transform: [{ scale: 0.98 }],
  },
  certCard: {
    flexDirection: "row",
    alignItems: "center",
    flexWrap: "wrap",
    marginTop: 15,
    padding: 13,
    borderRadius: 17,
    backgroundColor: "#FFFDF7",
    borderWidth: 1,
    borderColor: "#E7E6DC",
  },
  certIcon: {
    width: 34,
    height: 34,
    borderRadius: 11,
    backgroundColor: "#E7F2D8",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 10,
  },
  certCopy: {
    flex: 1,
    minWidth: 175,
    marginRight: 8,
  },
  certTitle: {
    color: "#17312C",
    fontSize: 13,
    fontWeight: "800",
  },
  certBody: {
    color: "#7A8881",
    fontSize: 10,
    lineHeight: 15,
    marginTop: 3,
  },
  secondaryButton: {
    paddingHorizontal: 10,
    paddingVertical: 8,
    borderRadius: 10,
    backgroundColor: "#E7F2D8",
    marginLeft: 4,
    marginTop: 4,
  },
  alreadyButton: {
    backgroundColor: "#EFF1EC",
  },
  secondaryButtonText: {
    color: "#315A36",
    fontSize: 10,
    fontWeight: "800",
  },
  footer: {
    paddingTop: 22,
    alignItems: "center",
  },
  footerText: {
    color: "#98A49D",
    fontSize: 10,
    lineHeight: 16,
    textAlign: "center",
  },
  pressed: {
    opacity: 0.72,
  },
});
